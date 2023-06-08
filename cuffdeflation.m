cuff = bigData(21).cuffdata{1,1}(bigData(21).cuffIdxs1{1,1}:bigData(21).cuffIdxs1{1,2}); %cuff = bigData(1).cuffRecordingIdxs(1,1);
figure()
plotxmldata = plot(cuff);
deflationcurve = plotxmldata;
 % set(gcf, 'position', 1.0e+03 * [-1.6663    0.2143    1.1560    0.5073]);

% plotting cuff BP as an oscillogram
sampletime = 0.004;
osc = Oscillogram(cuff, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 1);
    % set(gcf, 'position', 1.0e+03 * [-1.6663    0.2143    1.1560    0.5073]);

% beat detection of the oscillogram
[beatI, regionLimits] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1, ...
                            'RegionLimits', [max(cuff), length(cuff)], 'MinimumThreshold', 0.3, 'DerivativeAbsoluteThreshold', 0.01);
    % set(gcf, 'position', 1.0e+03 * [-1.6663    0.2143    1.1560    0.5073]);
