function Characteristics_redcap = getCharacteristics_redcap()
% This function improts data from characteristics_redcap file 
% Finds coloums with BPplus file names, THCI, and Date of study 
% import Characteristics_redcap.csv file

if ~exist('pathdef', 'var')
    pathdef = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data';
end 

filename = 'characteristics_redcap.csv';
readmatrix('characteristics_redcap.csv');
file = sprintf('%s\\%s',pathdef, filename);
data = readmatrix('characteristics_redcap.csv');
file_column = data(:, 2);
file_column = data(:, 4);
file_column = data(:, 17);
file_column = data(:, 20);
Characteristics_redcap = data(file_column);

end

%%

% read the CSV file into a table
data = readtable(file);

% select the column containing the XML file names
file_column = data(:, 2);
file_column = data(:, 4);
file_column = data(:, 17);
file_column = data(:, 20);

% structArray = table2struct(readtable(file))
% 
% Characteristics_redcap = readtable(file, file_column);
% 
% Characteristics_redcap = data(pathdef,file_column)

end
%%