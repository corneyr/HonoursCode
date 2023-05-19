function bigData = linkingxmltotxt()
% identifying the invasive and cuff files for each patient and matching
% them up to find if they are present in the data

characteristicsredcap = getCharacteristics_redcap();

home_path = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\';
%InvasiveBP\
%Hobart BP+\

bigData = struct;

for i = 1:height(characteristicsredcap)
    id = characteristicsredcap.thci(i); %for pointing to invasive recording
    cuffID1 = characteristicsredcap.measno_aor1(i); %for pointing to cuff1
    cuffID2 = characteristicsredcap.measno_aor2(i); %for pointing to cuff2

    bigData(i).id = id;
    bigData(i).cuffID = {};
    bigData(i).xml_path = {};
    bigData(i).invasive_path = {};
    bigData(i).cuffID{1} = cuffID1;
    bigData(i).cuffID{2} = cuffID2;
    disp("test")

    if ~isnan(cuffID1) %Check if Cuff recording exists
        two_files = dir(home_path +"\InvasiveBP\" + id + "*"); %the two invasive .txts
        if length(two_files) == 2 %some files are simply missing.
            disp(["Working on ID", id])
            for j = 1:2
                bigData(i).invasivedata = {};
                invasive_path = home_path +"\InvasiveBP\" + two_files(j).name;
                invasivedata = readtable(invasive_path);
                bigData(i).invasive_path{j} = invasive_path;
                bigData(i).invasivedata{j} = invasivedata.Var1;
                [bigData(i).cuffdata{j}, bigData(i).xml_path{j}] = getXMLfile(bigData(i).cuffID{j});
            end
        end
    
    end

end

end 


