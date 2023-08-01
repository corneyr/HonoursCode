function bigData = linkingxmltotxt(bigData)
% identifying the invasive and cuff files for each patient and matching
% them up to find if they are present in the data
% Savitzky-Golay smoothing filter applied to invasive aortic and brachial to dampen waveforms 
% Savitzky-Golay smoothing filter applied to dampen cuff BP waveforms 
% input: getCharacteristics_redcap 
% input: homepath to data location
% input: getXMLfile.m

characteristicsredcap = getCharacteristics_redcap();

home_path = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\';
%InvasiveBP\
%Hobart BP+\
%InvasiveBrachial\
if nargin == 0
    bigData = struct;
end

% for i = 1:height(characteristicsredcap)
 for i = 12
    id = characteristicsredcap.thci(i); %for pointing to invasive aorta and brachial recording
    cuffID1 = characteristicsredcap.measno_aor1(i); %for pointing to cuff1
    cuffID2 = characteristicsredcap.measno_aor2(i); %for pointing to cuff2

    bigData(i).id = id;
    bigData(i).cuffID = {};
    bigData(i).xml_path = {};
    bigData(i).invasive_path = {};
    bigData(i).invasivebrachial_path = {};
    bigData(i).cuffID{1} = cuffID1;
    bigData(i).cuffID{2} = cuffID2;
    
    if ~isnan(cuffID1) %Check if Cuff recording exists
        %Get invasive aortic data
        two_files = dir(home_path +"\InvasiveBP\" + id + "*"); %the two invasive aortic .txts
        if length(two_files) == 2 %some files are simply missing.
            disp(["Working on aortic ID", id])
            for j = 1:2
                invasive_path = home_path +"\InvasiveBP\" + two_files(j).name;
                invasivedata = readtable(invasive_path);
                bigData(i).invasive_path{j} = invasive_path;
                bigData(i).invasivedata{j} = invasivedata.Var1;
                bigData(i).filtered_invasivedata{j} = smooth(bigData(i).invasivedata{j}, 121, 'sgolay'); %S-G filter to smooth dampen waveforms
                [bigData(i).cuffdata{j}, bigData(i).xml_path{j}, full_xml_data] = getXMLfile(bigData(i).cuffID{j});
                bigData(i).cuff_sys{j} = str2double(full_xml_data.BPplus.MeasDataLogger.Sys.Text);
                bigData(i).cuff_dia{j} = str2double(full_xml_data.BPplus.MeasDataLogger.Dia.Text);
                bigData(i).cuff_map{j} = str2double(full_xml_data.BPplus.MeasDataLogger.Map.Text);

            end
        end

        %Detrend cuff data
        disp("Detrending cuff data")
        for j=1:length(bigData(i).cuffdata)
            [~, max_ind] = max(bigData(i).cuffdata{j});
            detrended_data = detrend( bigData(i).cuffdata{j}(max_ind:end), 3 );
            bigData(i).detrend_cuffdata{j} = detrended_data - min(detrended_data); 
            bigData(i).filtered_cuffdata{j} = smooth(bigData(i).detrend_cuffdata{j}, 10, 'sgolay');
        end

        %Get invasive brachial data if it exists.
        one_file = dir(home_path + "\InvasiveBrachial\" + id + "*"); %the invasive brachial .txts
        if length(one_file) == 1 
            disp(["Working on brachial ID",id])
            invasivebrachial_path = home_path + "\InvasiveBrachial\" + one_file.name;
            invasivebrachialdata = readtable(invasivebrachial_path);
            bigData(i).invasivebrachial_path = invasivebrachial_path;
            bigData(i).invasivebrachialdata = invasivebrachialdata.Var1;
            bigData(i).filtered_invasivebrachialdata = smooth(bigData(i).invasivebrachialdata, 121, 'sgolay'); %S-G filter to smooth dampen waveforms
        else
            disp(["Problem with brachial ID ", id])
        end
    end

    %Calculate important statistics from cuff data
    if ~iscell(bigData(i).cuffdata) || ~iscell(bigData(i).invasivedata)
                continue 
    else 
        if isfield(bigData, 'cuff_beatI')
            if isempty(bigData(i).cuff_beatI)
                for k = 1:length(bigData(i).cuffdata)
                    bigData(i).cuff_beatI{k} = calc_cuff_beati(bigData(i).filtered_cuffdata{k});
                end
            end
        else
            for k = 1:length(bigData(i).cuffdata)
                    bigData(i).cuff_beatI{k} = calc_cuff_beati(bigData(i).filtered_cuffdata{k});
            end
        end

    %Calculate important statistics from invasive aortic and brachial data
        if isfield(bigData, 'invasive_beatI')
            if isempty(bigData(i).invasive_beatI)
                for k = 1:length(bigData(i).filtered_invasivedata)
                    bigData(i).invasive_beatI{k} = calc_invasive_beatI(bigData(i).filtered_invasivedata{k});
                    bigData(i).invasive_average{k} = calc_invasive_average(bigData(i).filtered_invasivedata{k}, bigData(i).invasive_beatI{k});
                    
                    bigData(i).aortic_sys{k} = max(bigData(i).invasive_average{k});
                    bigData(i).aortic_dia{k} = min(bigData(i).invasive_average{k});
                    bigData(i).aortic_map{k} = mean(bigData(i).invasive_average{k});
                end
                if ~isempty(bigData(i).invasivebrachialdata)
                    bigData(i).invasivebrachialdata_beatI = calc_invasive_beatI(bigData(i).filtered_invasivebrachialdata);
                    bigData(i).invasivebrachial_average = calc_invasive_average(bigData(i).filtered_invasivebrachialdata,  bigData(i).invasivebrachialdata_beatI);

                    bigData(i).brachial_sys = max(bigData(i).invasivebrachial_average);
                    bigData(i).brachial_dia = min(bigData(i).invasivebrachial_average);
                    bigData(i).brachial_map = mean(bigData(i).invasivebrachial_average);

                end 
            end
        else
            for k = 1:length(bigData(i).filtered_invasivedata)
               bigData(i).invasive_beatI{k} = calc_invasive_beatI(bigData(i).filtered_invasivedata{k});
               bigData(i).invasive_average{k} = calc_invasive_average(bigData(i).filtered_invasivedata{k}, bigData(i).invasive_beatI{k});

               bigData(i).aortic_sys{k} = max(bigData(i).invasive_average{k});
               bigData(i).aortic_dia{k} = min(bigData(i).invasive_average{k});
               bigData(i).aortic_map{k} = mean(bigData(i).invasive_average{k});

            end
            if ~isempty(bigData(i).invasivebrachialdata)
               bigData(i).invasivebrachialdata_beatI = calc_invasive_beatI(bigData(i).filtered_invasivebrachialdata);
               bigData(i).invasivebrachial_average = calc_invasive_average(bigData(i).filtered_invasivebrachialdata,  bigData(i).invasivebrachialdata_beatI);                 
               bigData(i).brachial_sys = max(bigData(i).invasivebrachial_average);
               bigData(i).brachial_dia = min(bigData(i).invasivebrachial_average);
               bigData(i).brachial_map = mean(bigData(i).invasivebrachial_average);
            end 
         end
    end 


    %calculate Augmentation Indexs for Aortic, Brachial and each cuff
    %pulse.
    for k = 1:length(bigData(i).filtered_invasivedata)
        time_invasive = (0:(length(bigData(i).invasive_average{k})-1))*0.001;
        [bigData(i).aortic_AI{k}, ~, bigData(i).aortic_featuretimes{k}] = analysis.AugmentationIndex(time_invasive, bigData(i).invasive_average{k}, 'DoPlot',0);
    end
    if ~isempty(bigData(i).invasivebrachialdata)
        time_invasive = (0:(length(bigData(i).invasivebrachial_average)-1))*0.001;
        [bigData(i).brachial_AI, ~, bigData(i).brachial_featuretimes] = analysis.AugmentationIndex(time_invasive, bigData(i).invasivebrachial_average, 'DoPlot',0);
    end


    for k = 1:length(bigData(i).cuff_beatI)
        n_pulses = length(bigData(i).cuff_beatI{k})-1;
        bigData(i).cuff_AIx{k} = zeros(n_pulses, 1);
            for n = 1:n_pulses
                pulse = bigData(i).filtered_cuffdata{k}(bigData(i).cuff_beatI{k}(n):bigData(i).cuff_beatI{k}(n+1));
                time_cuff =  (0:(length(pulse)-1))*0.005;
                [bigData(i).cuff_AIx{k}(n), ~, bigData(i).cuff_featuretimes{k}{n}] = analysis.AugmentationIndex(time_cuff, pulse, 'DoPlot',0);
            end
    end



end 

function cuff_beatI = calc_cuff_beati(filtered_cuffdata)
    %Calcualtes when cuff beats start
    %Returns indices where cuffbeats start
    sampletime = 0.004;
    osc = Oscillogram(filtered_cuffdata, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 0);
    [cuff_beatI, ~] = analysis.BeatOnsetDetect(osc, 'Method', 'PeakCurvature', 'Interactive', 1,'RegionLimits', [max(filtered_cuffdata), length(filtered_cuffdata)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.05);
    % [cuff_beatI, ~] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(filtered_cuffdata), length(filtered_cuffdata)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.05);
    % cuff_beatI = cuff_beatI - 20;
    cuff_beatI =  round(cuff_beatI); 
end

% Detect invasive aortic beat indicies
function invasive_beatI = calc_invasive_beatI(filtered_invasivedata)
    [invasive_beatI, ~] = analysis.BeatOnsetDetect(filtered_invasivedata, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(filtered_invasivedata), length(filtered_invasivedata)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.55);
end

% Detect invasive aortic average 
function invasive_average = calc_invasive_average(filtered_invasivedata, invasive_beatI)
    invasive_average = analysis.AverageBeat(filtered_invasivedata', invasive_beatI, 1, 3); % '3' can include/excule good/bad data from average calculation, 0 for no plot, 1 for show plot 
end


end 
        
