function bigData = linkingxmltotxt()
% identifying the invasive and cuff files for each patient and matching
% them up to find if they are present in the data

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
    % cuffIdxs_S1 = characteristicsredcap.startI_1(i); %for pointing at start index 1
    % cuffIdxs_E1 = characteristicsredcap.endI_1(i); %for pointing at end index 1
    % cuffIdxs_S2 = characteristicsredcap.startI_2(i); %for pointing at start index 2
    % cuffIdxs_E2 = characteristicsredcap.endI_2(i); %for pointing at end index 1

    bigData(i).id = id;
    bigData(i).cuffID = {};
    bigData(i).xml_path = {};
    bigData(i).invasive_path = {};
    bigData(i).invasivebrachial_path = {};
    bigData(i).cuffID{1} = cuffID1;
    bigData(i).cuffID{2} = cuffID2;
    % bigData(i).cuffIdxs1 = {};
    % bigData(i).cuffIdxs1{1} = cuffIdxs_S1; %start of deflation cuff1
    % bigData(i).cuffIdxs1{2} = cuffIdxs_E1; %end of deflation cuff1
    % bigData(i).cuffIdxs2 = {};
    % bigData(i).cuffIdxs2{1} = cuffIdxs_S2; %start of deflation cuff2
    % bigData(i).cuffIdxs2{2} = cuffIdxs_E2; %end of deflation cuff2

    if ~isnan(cuffID1) %Check if Cuff recording exists
        %Get invasive aortic data
        two_files = dir(home_path +"\InvasiveBP\" + id + "*"); %the two invasive aortic .txts
        if length(two_files) == 2 %some files are simply missing.
            disp(["Working on ID", id])
            for j = 1:2
                invasive_path = home_path +"\InvasiveBP\" + two_files(j).name;
                invasivedata = readtable(invasive_path);
                bigData(i).invasive_path{j} = invasive_path;
                bigData(i).invasivedata{j} = invasivedata.Var1;
                [bigData(i).cuffdata{j}, bigData(i).xml_path{j}] = getXMLfile(bigData(i).cuffID{j});

            end
        end

        %Detrend cuff data
        disp("Detrending cuff data")
        for j=1:length(bigData(i).cuffdata)
            [~, max_ind] = max(bigData(i).cuffdata{j});
            detrended_data = detrend( bigData(i).cuffdata{j}(max_ind:end), 3 );
            bigData(i).detrend_cuffdata{j} = detrended_data - min(detrended_data); 
        end

        %Get invasive brachial data if it exists.
        one_file = dir(home_path + "\InvasiveBrachial\" + id + "*"); %the invasive brachial .txts
        if length(one_file) == 1 
            disp(["Working on brachial ID",id])
            invasivebrachial_path = home_path + "\InvasiveBrachial\" + one_file.name;
            invasivebrachialdata = readtable(invasivebrachial_path);
            bigData(i).invasivebrachial_path = invasivebrachial_path;
            bigData(i).invasivebrachialdata = invasivebrachialdata.Var1;
        else
            disp(["problem with ID ", id])
        end
    end 
end 

end 
        
