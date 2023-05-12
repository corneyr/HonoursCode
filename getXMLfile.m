function xml_data = getXMLfile(file_index, toppath)
% This function does ...
% Inputs: 
%  file_index: .... (e.g. for BPplus_00019.xml, file_index = 19)
%  toppath: where all the data is (subfolders are '0000', '0001', etc)
% Outputs:
%  data: the cuffPressure read from the XML file
% Example: data = GetDataFile(file_column{i,1},toppath)

if ~exist('toppath','var')
    toppath = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\Hobart BP+';
end
folderi = [1,20,39,59,80,100,117,140,160]; %First file in each folder.As files are in numeric order, if a files name is between two values in this list then the file is in the first folder in that range
foldern = 0:8;

%file_column = [2	17	21	25	NaN	30	32	34	36	38	40	42	44	46	48	50	54	56	58	60	63	65	67	69	71	73	75	79	81	83	85	87	89	NaN	91	93	95	97	99	101	103	106	108	110	112	114	116	118	120	122	124	NaN	126	128	130	133	136	139	141	143	146	149	152	157	160	NaN	167	169	171	173	175	NaN];

filename = sprintf('BPplus_%05.0f.xml', file_index); %change to curl braces if need be
foldernum = find(file_index >= folderi, 1, 'last');
filepath = fullfile(toppath, sprintf('%04.0f', foldern(foldernum)));

fprintf('\nProgress: %s \n', filename);
xml_data = ReadXML(fullfile(filepath, filename));
    % do something with the XML data,
end
