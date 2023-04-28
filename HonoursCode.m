%%%%% import Characteristics_redcap.csv file
%Characteristics_redcap 
pathdef = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\Data'
addpath('C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\Data')
filename = 'characteristics_redcap.csv';

file = sprintf('%s\\%s',pathdef, filename)

readtable(file)

% readtable('characteristics_redcap.csv')

%%%%%%%%% %import Characteristics_redcap.csv file


%[file,path] = uigetfile('*.*','Select one or more files','MultiSelect','on');

%InputFormat('dd/MM/uuuu mm:HH')

%datetime(file)

% read the CSV file into a table
data = readtable(file);

% select the column containing the XML file names
file_column = data(:, 17)
file_column = data(:, 20)

% loop over each file name in the column and open the corresponding XML file
num_files = height(file_column);
for i = 1:num_files
    file_name = file_column{i, 1};
    xml_data = xmlread(file_name);
    % do something with the XML data,
end



%BPplus data 
addpath('C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\Data\Hobart BP+\0000')
DOMnode = xmlread('BPplus_00001.xml')
readtable('BPplus_00001.xml')

