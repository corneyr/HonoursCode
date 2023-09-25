function filtvsunfilt = linkingxmltotxt1(filtvsunfilt)
% identifying the invasive and cuff files for each patient and matching
% them up to find if they are present in the data
% Savitzky-Golay smoothing filter applied to invasive aortic and brachial to dampen waveforms 
% Savitzky-Golay smoothing filter applied to dampen cuff BP waveforms 
% input: getCharacteristics_redcap 
% input: homepath to data location
% input: getXMLfile.m

characteristicsredcap = getCharacteristics_redcap();

home_path = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\';
%InvasiveaortaBP\
%Hobart BP+\
%InvasiveBrachial\
if nargin == 0
    filtvsunfilt = struct;
end

% for i = 1:height(characteristicsredcap)
for i = 70:90
    id = characteristicsredcap.thci(i); %for pointing to invasive aorta and brachial recording
    cuffID1 = characteristicsredcap.measno_aor1(i); %for pointing to cuff1
    cuffID2 = characteristicsredcap.measno_aor2(i); %for pointing to cuff2

    filtvsunfilt(i).id = id;
    filtvsunfilt(i).cuffID = {};
    filtvsunfilt(i).xml_path = {};
    filtvsunfilt(i).invasive_path = {};
    filtvsunfilt(i).invasivebrachial_path = {};
    filtvsunfilt(i).cuffID{1} = cuffID1;
    filtvsunfilt(i).cuffID{2} = cuffID2;
    
    if ~isnan(cuffID1) %Check if Cuff recording exists
        %Get invasive aortic data
        two_files = dir(home_path +"\InvasiveBP\" + id + "*"); %the two invasive aortic .txts
        if length(two_files) == 2 %some files are simply missing.
            disp(["Working on aortic ID", id])
            for j = 1:2
                invasive_path = home_path +"\InvasiveBP\" + two_files(j).name;
                invasivedata = readtable(invasive_path);
                filtvsunfilt(i).invasive_path{j} = invasive_path;
                filtvsunfilt(i).invasivedata{j} = invasivedata.Var1;
                filtvsunfilt(i).filtered_invasivedata{j} = smooth(filtvsunfilt(i).invasivedata{j}, 121, 'sgolay'); %S-G filter to smooth dampen waveforms
                [filtvsunfilt(i).cuffdata{j}, filtvsunfilt(i).xml_path{j}, full_xml_data] = getXMLfile(filtvsunfilt(i).cuffID{j});
                filtvsunfilt(i).cuff_sys{j} = str2double(full_xml_data.BPplus.MeasDataLogger.Sys.Text);
                filtvsunfilt(i).cuff_dia{j} = str2double(full_xml_data.BPplus.MeasDataLogger.Dia.Text);
                filtvsunfilt(i).cuff_map{j} = str2double(full_xml_data.BPplus.MeasDataLogger.Map.Text);

            end
        end

        %Detrend cuff data
        disp("Detrending cuff data")
        for j=1:length(filtvsunfilt(i).cuffdata)
            [~, max_ind] = max(filtvsunfilt(i).cuffdata{j});
            detrended_data = detrend( filtvsunfilt(i).cuffdata{j}(max_ind:end), 3 );
            filtvsunfilt(i).detrend_cuffdata{j} = detrended_data - min(detrended_data); 
            filtvsunfilt(i).filtered_cuffdata{j} = smooth(filtvsunfilt(i).detrend_cuffdata{j}, 10, 'sgolay');
        end

        %Get invasive brachial data if it exists.
        one_file = dir(home_path + "\InvasiveBrachial\" + id + "*"); %the invasive brachial .txts
        if length(one_file) == 1 
            disp(["Working on brachial ID",id])
            invasivebrachial_path = home_path + "\InvasiveBrachial\" + one_file.name;
            invasivebrachialdata = readtable(invasivebrachial_path);
            filtvsunfilt(i).invasivebrachial_path = invasivebrachial_path;
            filtvsunfilt(i).invasivebrachialdata = invasivebrachialdata.Var1;
            filtvsunfilt(i).filtered_invasivebrachialdata = smooth(filtvsunfilt(i).invasivebrachialdata, 121, 'sgolay'); %S-G filter to smooth dampen waveforms
        else
            disp(["Problem with brachial ID ", id])
        end
    end

    %Calculate important statistics from cuff data
    if ~iscell(filtvsunfilt(i).cuffdata) || ~iscell(filtvsunfilt(i).invasivedata)
                continue 
    else 
        if isfield(filtvsunfilt, 'cuff_beatI')
            if isempty(filtvsunfilt(i).cuff_beatI)
                for k = 1:length(filtvsunfilt(i).cuffdata)
                    filtvsunfilt(i).cuff_beatI{k} = calc_cuff_beati(filtvsunfilt(i).filtered_cuffdata{k});
                end
            end
        else
            for k = 1:length(filtvsunfilt(i).cuffdata)
                    filtvsunfilt(i).cuff_beatI{k} = calc_cuff_beati(filtvsunfilt(i).filtered_cuffdata{k});
            end
        end

    %Calculate important statistics from invasive aortic and brachial data
        if isfield(filtvsunfilt, 'invasive_beatI')
            if isempty(filtvsunfilt(i).invasive_beatI)
                for k = 1:length(filtvsunfilt(i).filtered_invasivedata)
                    filtvsunfilt(i).invasive_beatI{k} = calc_invasive_beatI(filtvsunfilt(i).filtered_invasivedata{k});
                    filtvsunfilt(i).invasive_average{k} = calc_invasive_average(filtvsunfilt(i).filtered_invasivedata{k}, filtvsunfilt(i).invasive_beatI{k});
                    filtvsunfilt(i).invasiveunfiltered_beatI{k} = calc_invasiveunfiltered_beatI(filtvsunfilt(i).invasivedata{k});
                    filtvsunfilt(i).invasiveunfiltered_average{k} = calc_invasiveunfiltered_average(filtvsunfilt(i).invasivedata{k}, filtvsunfilt(i).invasiveunfiltered_beatI{k});
                    
                    filtvsunfilt(i).aortic_sys{k} = max(filtvsunfilt(i).invasive_average{k});
                    filtvsunfilt(i).aortic_dia{k} = min(filtvsunfilt(i).invasive_average{k});
                    filtvsunfilt(i).aortic_map{k} = mean(filtvsunfilt(i).invasive_average{k});

                    filtvsunfilt(i).aortic_sys_unfiltered{k} = max(filtvsunfilt(i).invasiveunfiltered_average{k});
                    filtvsunfilt(i).aortic_dia_unfiltered{k}  = min(filtvsunfilt(i).invasiveunfiltered_average{k});
                    filtvsunfilt(i).aortic_map_unfiltered{k} = mean(filtvsunfilt(i).invasiveunfiltered_average{k});

                end
                if ~isempty(filtvsunfilt(i).invasivebrachialdata)
                    filtvsunfilt(i).invasivebrachialdata_beatI = calc_invasive_beatI(filtvsunfilt(i).filtered_invasivebrachialdata);
                    filtvsunfilt(i).invasivebrachial_average = calc_invasive_average(filtvsunfilt(i).filtered_invasivebrachialdata,  filtvsunfilt(i).invasivebrachialdata_beatI);
                    
                    filtvsunfilt(i).invasivebrachialdataunfiltered_beatI = calc_invasive_beatI(filtvsunfilt(i).invasivebrachialdata);
                    filtvsunfilt(i).invasivebrachialunfiltered_average = calc_invasive_average(filtvsunfilt(i).invasivebrachialdata, filtvsunfilt(i).invasivebrachialdataunfiltered_beatI);

                    filtvsunfilt(i).brachial_sys = max(filtvsunfilt(i).invasivebrachial_average);
                    filtvsunfilt(i).brachial_dia = min(filtvsunfilt(i).invasivebrachial_average);
                    filtvsunfilt(i).brachial_map = mean(filtvsunfilt(i).invasivebrachial_average);
                    
                    filtvsunfilt(i).brachialunfiltered_sys = max(filtvsunfilt(i).invasivebrachialunfiltered_average);
                    filtvsunfilt(i).brachialunfiltered_dia = min(filtvsunfilt(i).invasivebrachialunfiltered_average);
                    filtvsunfilt(i).brachialunfiltered_map = mean(filtvsunfilt(i).invasivebrachialunfiltered_average);
                    
                end 
            end
        else
            for k = 1:length(filtvsunfilt(i).filtered_invasivedata)
                filtvsunfilt(i).invasive_beatI{k} = calc_invasive_beatI(filtvsunfilt(i).filtered_invasivedata{k});
                filtvsunfilt(i).invasive_average{k} = calc_invasive_average(filtvsunfilt(i).filtered_invasivedata{k}, filtvsunfilt(i).invasive_beatI{k});
                filtvsunfilt(i).invasiveunfiltered_beatI{k} = calc_invasiveunfiltered_beatI(filtvsunfilt(i).invasivedata{k});
                filtvsunfilt(i).invasiveunfiltered_average{k} = calc_invasiveunfiltered_average(filtvsunfilt(i).invasivedata{k}, filtvsunfilt(i).invasiveunfiltered_beatI{k});
                
                filtvsunfilt(i).aortic_sys{k} = max(filtvsunfilt(i).invasive_average{k});
                filtvsunfilt(i).aortic_dia{k} = min(filtvsunfilt(i).invasive_average{k});
                filtvsunfilt(i).aortic_map{k} = mean(filtvsunfilt(i).invasive_average{k});
    
                filtvsunfilt(i).aortic_sys_unfiltered{k} = max(filtvsunfilt(i).invasiveunfiltered_average{k});
                filtvsunfilt(i).aortic_dia_unfiltered{k}  = min(filtvsunfilt(i).invasiveunfiltered_average{k});
                filtvsunfilt(i).aortic_map_unfiltered{k} = mean(filtvsunfilt(i).invasiveunfiltered_average{k});
            end
            if ~isempty(filtvsunfilt(i).invasivebrachialdata)
                filtvsunfilt(i).invasivebrachialdata_beatI = calc_invasive_beatI(filtvsunfilt(i).filtered_invasivebrachialdata);
                filtvsunfilt(i).invasivebrachial_average = calc_invasive_average(filtvsunfilt(i).filtered_invasivebrachialdata,  filtvsunfilt(i).invasivebrachialdata_beatI);
                filtvsunfilt(i).invasivebrachialdataunfiltered_beatI = calc_invasive_beatI(filtvsunfilt(i).invasivebrachialdata);
                filtvsunfilt(i).invasivebrachialunfiltered_average = calc_invasive_average(filtvsunfilt(i).invasivebrachialdata,  filtvsunfilt(i).invasivebrachialdataunfiltered_beatI);

                filtvsunfilt(i).brachial_sys = max(filtvsunfilt(i).invasivebrachial_average);
                filtvsunfilt(i).brachial_dia = min(filtvsunfilt(i).invasivebrachial_average);
                filtvsunfilt(i).brachial_map = mean(filtvsunfilt(i).invasivebrachial_average);
                
                filtvsunfilt(i).brachialunfiltered_sys = max(filtvsunfilt(i).invasivebrachialunfiltered_average);
                filtvsunfilt(i).brachialunfiltered_dia = min(filtvsunfilt(i).invasivebrachialunfiltered_average);
                filtvsunfilt(i).brachialunfiltered_map = mean(filtvsunfilt(i).invasivebrachialunfiltered_average);
            end 
         end
    end 


    %calculate Augmentation Indexs for Aortic, Brachial and each cuff
    %pulse.
    for k = 1:length(filtvsunfilt(i).filtered_invasivedata)
        time_invasive = (0:(length(filtvsunfilt(i).invasive_average{k})-1))*0.001;
        [filtvsunfilt(i).aortic_AI{k}, ~, filtvsunfilt(i).aortic_featuretimes{k}] = analysis.AugmentationIndex(time_invasive, filtvsunfilt(i).invasive_average{k}, 'InflectionPointProminenceThreshold', 0.05, 'DoPlot',0);
    end
    if ~isempty(filtvsunfilt(i).invasivebrachialdata)
        time_invasive = (0:(length(filtvsunfilt(i).invasivebrachial_average)-1))*0.001;
        [filtvsunfilt(i).brachial_AI, ~, filtvsunfilt(i).brachial_featuretimes] = analysis.AugmentationIndex(time_invasive, filtvsunfilt(i).invasivebrachial_average, 'InflectionPointProminenceThreshold', 0.05, 'DoPlot',0);
    end


    for k = 1:length(filtvsunfilt(i).cuff_beatI)
        n_pulses = length(filtvsunfilt(i).cuff_beatI{k})-1;
        filtvsunfilt(i).cuff_AIx{k} = zeros(n_pulses, 1);
            for n = 1:n_pulses
                pulse = filtvsunfilt(i).filtered_cuffdata{k}(filtvsunfilt(i).cuff_beatI{k}(n):filtvsunfilt(i).cuff_beatI{k}(n+1));
                time_cuff =  (0:(length(pulse)-1))*0.005;
                [filtvsunfilt(i).cuff_AIx{k}(n), ~, filtvsunfilt(i).cuff_featuretimes{k}{n}] = analysis.AugmentationIndex(time_cuff, pulse, 'InflectionPointProminenceThreshold', 0.05, 'DoPlot',0);
            end
    end



end 

function cuff_beatI = calc_cuff_beati(filtered_cuffdata)
    %Calcualtes when cuff beats start
    %Returns indices where cuffbeats start
    sampletime = 0.004;
    osc = Oscillogram(filtered_cuffdata, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 0);
    [cuff_beatI, ~] = analysis.BeatOnsetDetect(osc, 'Method', 'PeakCurvature', 'CurvatureThreshold', 0.7, 'Interactive', 1,'RegionLimits', [max(filtered_cuffdata), length(filtered_cuffdata)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.05);
    cuff_beatI =  round(cuff_beatI); 
end

% Detect invasive aortic beat indicies
function invasive_beatI = calc_invasive_beatI(filtered_invasivedata)
    [invasive_beatI, ~] = analysis.BeatOnsetDetect(filtered_invasivedata, 'Method', 'PeakCurvature', 'CurvatureThreshold', 0.7, 'Interactive', 1,'RegionLimits', [max(filtered_invasivedata), length(filtered_invasivedata)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.55);
end

function invasiveunfiltered_beatI = calc_invasiveunfiltered_beatI(invasivedata)
    [invasiveunfiltered_beatI, ~] = analysis.BeatOnsetDetect(invasivedata, 'Method', 'PeakCurvature', 'CurvatureThreshold', 0.7, 'Interactive', 1,'RegionLimits', [max(invasivedata), length(invasivedata)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.55);
end

% Detect invasive aortic average 
function invasive_average = calc_invasive_average(filtered_invasivedata, invasive_beatI)
    invasive_average = analysis.AverageBeat(filtered_invasivedata', invasive_beatI, 1, 3); % '3' can include/excule good/bad data from average calculation, 0 for no plot, 1 for show plot 
end

function invasiveunfiltered_average = calc_invasiveunfiltered_average(invasivedata, invasiveunfiltered_beatI)
    invasiveunfiltered_average = analysis.AverageBeat(invasivedata', invasiveunfiltered_beatI, 1, 3); % '3' can include/excule good/bad data from average calculation, 0 for no plot, 1 for show plot 
end

end 
        
