function xmldatafigure = plotxmldata(path)

    % finds xml data pathway
    % reads xml data 
    % plots xml data in mmHg

    disp(nargin)

if nargin == 0
% xml files pathway
    [fn, path] = uigetfile();

    pathFile = [path fn];
else
    pathFile = path;
end

% Plotting the xml file
cuffPressure = ReadXML(pathFile);
figure()
plotxmldata = plot(cuffPressure);
xmldatafigure = plotxmldata;
 % set(gcf, 'position', 1.0e+03 * [-1.6663    0.2143    1.1560    0.5073]);

% plotting cuff BP as an oscillogram
sampletime = 0.004;
osc = Oscillogram(cuffPressure, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 1);
    % set(gcf, 'position', 1.0e+03 * [-1.6663    0.2143    1.1560    0.5073]);

% beat detection of the oscillogram
[beatI, regionLimits] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1, ...
                            'RegionLimits', [max(cuffPressure), length(cuffPressure)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.05);
    % set(gcf, 'position', 1.0e+03 * [-1.6663    0.2143    1.1560    0.5073]);

beatI = round(beatI);
dt = 1/200;
for m = 1:4
    for n = 1:4
        linearIndex = (m-1)*4+n;
        disp(linearIndex)
        starti = beatI(linearIndex);
        endi = beatI(linearIndex+1);
        pulse = cuffPressure(starti:endi);
        time = (0:(length(pulse)-1))*dt;
        [AI, Paug, featuretimes] = AugmentationIndex(time, pulse, 'DoPlot',1);
    end
end


end