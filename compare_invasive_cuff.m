% plot(bigData(1).invasivedata{1,2})


%for i = 1:length(bigData)
i = 1;

%Note to self, we probably want to rewrite this back into bigData at some
%point
invasive_average = calc_invasive_average(bigData, 71);
invasive_brachial_average = calc_invasive_brachial_average(bigData, 71);
cuff_beatI = calc_cuff_beati(bigData, 71);

num_cols = 5;
num_rows = ceil((length(cuff_beatI)-1)/num_cols)+1;

subplot(num_rows, num_cols, 1)
t = plot_aug_idx(invasive_average, 0.001);
t.String = "Aortic " + t.String;

subplot(num_rows, num_cols, num_cols)
t = plot_aug_idx(invasive_brachial_average, 0.001);
t.String = "Brachial " + t.String;

for n = 1:(length(cuff_beatI)-1)
    subplot(num_rows, num_cols, num_cols+n)
    plot_aug_idx(bigData(71).cuffdata{1,2}(cuff_beatI(n):cuff_beatI(n+1)), 0.02)
    % xlim([0, 1]) %shrinks invasive to 1second
end


function t = plot_aug_idx(pulse, dt)
    time = (0:(length(pulse)-1))*dt;
    [AI, ~, featuretimes] = AugmentationIndex(time, pulse, 'DoPlot',0);

    plot(time, pulse);
    
    if isstruct(featuretimes)

        x1 = xline(featuretimes.maxP,'-','Max P');
        x2 = xline(featuretimes.shoulder,'-','Shoulder');
        x3 = xline( featuretimes.inflection,'-','Inflection');

        x1.LabelVerticalAlignment = 'middle';
        x1.LabelHorizontalAlignment = 'center';

        x2.LabelVerticalAlignment = 'middle';
        x2.LabelHorizontalAlignment = 'center';

        x3.LabelVerticalAlignment = 'middle';
        x3.LabelHorizontalAlignment = 'center';

        t = title(['AI = ', num2str(AI)]);
    end

end



function cuff_beatI = calc_cuff_beati(bigData, subject)
    sampletime = 0.004;
    osc = Oscillogram(bigData(subject).cuffdata{1,2}, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 0);
    [cuff_beatI, ~] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(bigData(subject).cuffdata{1,2}), length(bigData(subject).cuffdata{1,2})], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.05);
    cuff_beatI = round(cuff_beatI); 
end


%Detect cuff pulses




function invasive_average = calc_invasive_average(bigData, subject)
    [beatI, ~] = analysis.BeatOnsetDetect(bigData(subject).invasivedata{1,2}, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(bigData(subject).invasivedata{1,2}), length(bigData(subject).invasivedata{1,2})], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.55);
    invasive_average = analysis.AverageBeat(bigData(subject).invasivedata{1,2}', beatI, 1, 0);
end

function invasive_brachial_average = calc_invasive_brachial_average(bigData, subject)
    [beatI, ~] = analysis.BeatOnsetDetect(bigData(subject).invasivebrachialdata, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(bigData(subject).invasivebrachialdata), length(bigData(subject).invasivebrachialdata)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.55);
    invasive_brachial_average = analysis.AverageBeat(bigData(subject).invasivebrachialdata', beatI, 1, 0);
end