function [xml_data, xml_path, full_xml_data] = getXMLfile(file_index, toppath)
% This function does ...
% Inputs: 
%  file_index: .... (e.g. for BPplus_00019.xml, file_index = 19)
%  toppath: where all the data is (subfolders are '0000', '0001', etc)
%  number of folders with data (foldern = 0:9)
%  file number at begining (folderi = [1,20...]
%  pathway to data
% Outputs:
%   data: the cuffPressure read from the XML file
% Example: data = GetDataFile(file_column{i,1},toppath)


if ~exist('toppath','var')
    toppath = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\Hobart BP+';
end
folderi = [1,20,39,59,80,100,117,140,160,180,200]; %First file in each folder.
foldern = 0:10;

filename = sprintf('BPplus_%05.0f.xml', file_index); %change to curl braces if need be
foldernum = find(file_index >= folderi, 1, 'last');
xml_path = fullfile(toppath, sprintf('%04.0f', foldern(foldernum)), filename);

fprintf('\nProgress: %s \n', filename);

if isfile(xml_path)
    [xml_data, full_xml_data] = ReadXML(xml_path);
else
    xml_data = NaN;
    disp("Could not find " + xml_path)
end
