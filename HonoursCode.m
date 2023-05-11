%% import Characteristics_redcap file and pull out thci, date_of_study, cuffbp1, cuffbp2
characteristicsredcap = getCharacteristics_redcap
%%

%% getXMLfile from cvs file
xml_data = getXMLfile(file_index, toppath)
% Example: xml_data = getXMLfile(43)  
% then: plot(xml_data)
%%

%% plotting the cuff BP xml data 
plotxmldata = plot(cuffPressure);

% plotting cuff BP as an oscillogram
sampletime = 0.004;
osc = Oscillogram(cuffPressure, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 1);
%set(gcf, 'position', 1.0e+03 * [-1.6663    0.2143    1.1560    0.5073]);

% beat detection of the oscillogram
[~,maxI] = max(cuffPressure);
[beatI, regionLimits] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1, ...
                            'RegionLimits', [maxI, length(cuffPressure)], 'MinimumThreshold', 0.3, 'DerivativePeakThreshold', 0.05);
%%

%% pathway to invasive files
% plot invasvie files in mmHg
plotinvasive = plot(invasivedata.Var1);
%%