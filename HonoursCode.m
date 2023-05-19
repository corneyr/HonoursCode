%% import Characteristics_redcap file and pull out thci, date_of_study, cuffbp1, cuffbp2
% may not be needed being used for the bigData function instead
characteristicsredcap = getCharacteristics_redcap();
%%

%% get xml name from files csv file
% xml_data = getXMLfile(file_index, toppath); example: xml_data = getXMLfile(23);
% bigdata is finding the xml and txt file names from the redcap csv file.
bigData = linkingxmltotxt();
%%

%% plotting the cuff BP xml data 
% may not be needed anymore - replaced by getxmldirectory
xmldatafigure = plotxmldata;
%%

%% pathway to invasive files
% plot invasvie files in mmHg
% may not be needed anymore
invasivefigure = plotinvasive(path_file);
%%

%% Finding xml files and producing the figures 
% getxmldirectory
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
