function invasivefigure = plotinvasive(path)
% pathway to invasive files


if nargin == 0
% xml files pathway
    [fn, path] = uigetfile("*.*");

    pathFile = [path fn];
else
    pathFile = path;
end

% Plot invasive data in mmHg
%readtable(pathFile);
invasivedata = readtable(pathFile);
figure()
invasivefigure = plot(invasivedata.Var1);
% ax = gca;
% exportgraphics(ax, 'invasiveplot.jpg')

[beatI, regionLimits] = analysis.BeatOnsetDetect(invasivedata.Var1, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(invasivedata.Var1), length(invasivedata.Var1)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.55);

beatI = round(beatI);
for n = 1:length(beatI)
    starti = beatI(n);
    endi = beatI(n+1);
    pulse = invasivedata.Var1(starti:endi);
    time = (0:(length(pulse)-1))*0.001;
    [AI, Paug, featuretimes] = AugmentationIndex(time, pulse, 'DoPlot',1);
end 
end

