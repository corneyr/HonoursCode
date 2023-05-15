%% import Characteristics_redcap file and pull out thci, date_of_study, cuffbp1, cuffbp2
characteristicsredcap = getCharacteristics_redcap;
%%

%% get xml name from files csv file
% xml_data = getXMLfile(file_index, toppath);
xml_data = getXMLfile(23);  
%%

%% plotting the cuff BP xml data 
% may not be needed anymore
xmldatafigure = plotxmldata;
%%

%% pathway to invasive files
% plot invasvie files in mmHg
invasivefigure = plotinvasive;
%%

%% Finding xml files and producing the figures
outerDirectoryName = "C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\Hobart BP+";

outerDirectory = dir(outerDirectoryName);

for i = 1:length(outerDirectory)
    if outerDirectory(i).name ~= "." && outerDirectory(i).name ~= ".."
        %We should check that these are directories just in case someone
        %slips in a file into Hobart BP+
        innerDirectory = dir(outerDirectoryName  + "\" + outerDirectory(i).name);
        for j = 1:length(innerDirectory)
            if ~innerDirectory(j).isdir
                path = outerDirectoryName  + "\" + outerDirectory(i).name + "\" + innerDirectory(j).name;
                plotxmldata(path);
            end
        end
    end
end
%%
