%% import Characteristics_redcap file and pull out thci, date_of_study, cuffbp1, cuffbp2
characteristicsredcap = getCharacteristics_redcap
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
