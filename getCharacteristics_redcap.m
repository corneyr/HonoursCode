function characteristicsredcap = getCharacteristics_redcap()
% This function improts data from characteristics_redcap file 
% Finds coloums with BPplus file names, THCI, and Date of study 
% import Characteristics_redcap.csv file
% input: homepath to data location 

if ~exist('pathdef', 'var')
    pathdef = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data';
end 

% file = sprintf('%s\\%s',pathdef, filename);
% data = readtable(file,opts);
filename = 'characteristics_redcap.csv';
fullpath = fullfile(pathdef,filename);
opts = detectImportOptions(fullpath);

% Specify column names and types
opts.SelectedVariableNames = ["thci", "date_of_study", "measno_aor1", "measno_aor2"];
opts = setvaropts(opts, "date_of_study", "InputFormat", "dd/MM/yyyy");

% Import the data
characteristicsredcap = readtable(fullpath, opts);

end
