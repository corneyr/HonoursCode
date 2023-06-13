% beatI already generated from
cuffPressure = bigData(21).cuffdata{1,2};
osc = Oscillogram(cuffPressure, 1/200, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 1);
[beatI, regionLimits] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1, ...
                            'RegionLimits', [max(cuffPressure), length(cuffPressure)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.05);
% screws up the last pulse, just rememeber

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

%augmentation index only works when you use the whole inflation/deflation
%cycle 