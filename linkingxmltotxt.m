function bigData = linkingxmltotxt()
% identifying the invasive and cuff files for each patient and matching
% them up to find if they are present in the data
% Savitzky-Golay smoothing filter applied to invasive aortic and brachial to dampen waveforms
% input: getCharacteristics_redcap 
% input: homepath to data location
% input: getXMLfile.m

characteristicsredcap = getCharacteristics_redcap();

home_path = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\';
%InvasiveBP\
%Hobart BP+\
%InvasiveBrachial\

bigData = struct;

for i = 1:height(characteristicsredcap)
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
            disp(["problem with brachial ID ", id])
        end
    end 
end 

end 
        
