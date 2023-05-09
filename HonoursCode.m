%%%%% import Characteristics_redcap.csv file
%Characteristics_redcap 
pathdef = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data'
addpath('C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data');
filename = 'characteristics_redcap.csv';

file = sprintf('%s\\%s',pathdef, filename);

% readtable('characteristics_redcap.csv')

%%%%% %import Characteristics_redcap.csv file

%[file,path] = uigetfile('*.*','Select one or more files','MultiSelect','on');

%InputFormat('dd/MM/uuuu mm:HH')

%datetime(file)

% read the CSV file into a table
data = readtable(file);

% select the column containing the XML file names
file_column = data(:, 2);
file_column = data(:, 4);
file_column = data(:, 17);
file_column = data(:, 20);


%%%Reading in the xml files
[fn, path] = uigetfile();

%%%Plotting the xml file
%cuffPressure = ReadXML('C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\Hobart BP+\0000/0000/BPplus_00001.xml')
cuffPressure = xmlread([path fn], 'AllowDoctype',true);
getFirstChild(cuffPressure);
cuffPressure = ReadXML([path fn]);
plot(cuffPressure);
%%%Plotting the xml file

sampletime = 0.004;
osc = Oscillogram(cuffPressure, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 1);
%set(gcf, 'position', 1.0e+03 * [-1.6663    0.2143    1.1560    0.5073]);

%%%beat detection%%%
[~,maxI] = max(cuffPressure);
[beatI, regionLimits] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1, ...
                            'RegionLimits', [maxI, length(cuffPressure)], 'MinimumThreshold', 0.3, 'DerivativePeakThreshold', 0.05);
%%%beat detection%%%

%%%pathway to invasive files%%
addpath('C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\InvasiveBP\');
%%%pathway to invasive files%%

%%Plot invasive data%%
readtable('100176076_22062022_cuff1_P.txt')
invasivedata = readtable('100176076_22062022_cuff1_P.txt');
plot(invasivedata.Var1);
%%Plot invasive data%%
