%% import Characteristics_redcap file and pull out thci, date_of_study, cuffbp1, cuffbp2
characteristicsredcap = getCharacteristics_redcap;
%%

%% getXMLfile from cvs file
% xml_data = getXMLfile(file_index, toppath);
xml_data = getXMLfile(43);  
%%

%% plotting the cuff BP xml data 
xmldatafigure = plotxmldata;
%%

%% pathway to invasive files
% plot invasvie files in mmHg
invasivefigure = plotinvasive;
%%