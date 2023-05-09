function data = GetDataFile(file_index, toppath)
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
folderi = [1,20,39,59,80,100,117,140,160];
foldern = 0:8;

num_files = height(file_column);
for i = 1:num_files

    filename = sprintf('BPplus_%05.0f.xml', file_column{i,1});
    foldernum = find(file_column{i,1} >= folderi, 1, 'first');
    filepath = fullfile(toppath, sprintf('%04.0f', foldern(foldernum)));

    fprintf('\nProgress: %s', filename);
    xml_data = ReadXML(fullfile(filepath, filename));
    % do something with the XML data,
end



%% not needed
addpath('C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\Hobart BP+\0000');
DOMnode = xmlread('BPplus_00001.xml');
readtable('BPplus_00001.xml');
xmlread('BPplus_00001.xml');

%%%Reading in the xml files

% Define the XML file name

xmlFileName = 'BPplus_00001.xml';

% Read the XML file

xmlData = xmlread(xmlFileName);

% Get the root node of the XML document

rootNode = xmlData.getDocumentElement();

% Get all child nodes of the root node

childNodes = rootNode.getChildNodes();

% Loop through all child nodes and extract the variables

for i = 1:childNodes.getLength()

    node = childNodes.item(i-1);

    if node.getNodeType() == node.ELEMENT_NODE

        nodeName = char(node.getNodeName());

        nodeValue = char(node.getTextContent());

        % Output the variables

        fprintf('%s = %s\n', nodeName, nodeValue);

    end

end
%% not needed
