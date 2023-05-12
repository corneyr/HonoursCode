function xmldatafigure = plotxmldata;

    % finds xml data pathway
    % reads xml data 
    % plots xml data in mmHg

% xml files pathway
[fn, path] = uigetfile();

% Plotting the xml file
cuffPressure = xmlread([path fn], 'AllowDoctype',true);
getFirstChild(cuffPressure);
cuffPressure = ReadXML([path fn]);
plot(cuffPressure);
plotxmldata = plot(cuffPressure);

xmldatafigure = plotxmldata;

% plotting cuff BP as an oscillogram
sampletime = 0.004;
osc = Oscillogram(cuffPressure, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 1);
% set(gcf, 'position', 1.0e+03 * [-1.6663    0.2143    1.1560    0.5073]);

% beat detection of the oscillogram
[~,maxI] = max(cuffPressure);
[beatI, regionLimits] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1, ...
                            'RegionLimits', [maxI, length(cuffPressure)], 'MinimumThreshold', 0.3, 'DerivativePeakThreshold', 0.05);

end