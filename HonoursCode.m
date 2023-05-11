%% import Characteristics_redcap.csv file
if ~exist('pathdef', 'var')
    pathdef = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data';
end 

% file = sprintf('%s\\%s',pathdef, filename);
% data = readtable(file,opts);
filename = 'characteristics_redcap.csv';
opts = detectImportOptions(filename);

% Specify column names and types
opts.SelectedVariableNames = ["thci", "date_of_study", "measno_aor1", "measno_aor2"];
opts = setvaropts(opts, "date_of_study", "InputFormat", "dd/MM/yyyy");

% Import the data
characteristicsredcap = readtable(filename, opts);
%%

%% getXMLfile from cvs file
xml_data = getXMLfile(file_index, toppath)
%Example: xml_data = getXMLfile(43)  then: plot(xml_data)
%%

%% xml files
[fn, path] = uigetfile();

%%%Plotting the xml file
%cuffPressure = ReadXML('C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\Hobart BP+\0000/0000/BPplus_00001.xml')
cuffPressure = xmlread([path fn], 'AllowDoctype',true);
getFirstChild(cuffPressure);
cuffPressure = ReadXML([path fn]);
plot(cuffPressure);

sampletime = 0.004;
osc = Oscillogram(cuffPressure, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 1);
%set(gcf, 'position', 1.0e+03 * [-1.6663    0.2143    1.1560    0.5073]);

% beat detection
[~,maxI] = max(cuffPressure);
[beatI, regionLimits] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1, ...
                            'RegionLimits', [maxI, length(cuffPressure)], 'MinimumThreshold', 0.3, 'DerivativePeakThreshold', 0.05);
%%

%% pathway to invasive files
addpath('C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\InvasiveBP\');
%% pathway to invasive files

%% Plot invasive data
readtable('100176076_22062022_cuff1_P.txt')
invasivedata = readtable('100176076_22062022_cuff1_P.txt');
plot(invasivedata.Var1);
%% Plot invasive data
