
% for i = 1:length(bigData)
%     if ~iscell(bigData(i).invasivedata) || ~iscell(bigData(i).cuffdata) || isempty(bigData(i).invasivebrachialdata)
%         continue
%     end

i = 7;

% Note to self, we probably want to rewrite this back into bigData at some
% point
invasive_average = calc_invasive_average(bigData, i);
invasive_brachial_average = calc_invasive_brachial_average(bigData, i);
cuff_beatI = calc_cuff_beati(bigData, i);

% plotting the aortic, brachial and cuff on one plot
num_cols = 5;
num_rows = ceil((length(cuff_beatI)-1)/num_cols)+1;

subplot(num_rows, num_cols, 1);
t = plot_aug_idx(invasive_average, 0.001);
t.String = "Aortic " + t.String;

subplot(num_rows, num_cols, num_cols);
t = plot_aug_idx(invasive_brachial_average, 0.001);
t.String = "Brachial " + t.String;

for n = 1:(length(cuff_beatI)-1)
    subplot(num_rows, num_cols, num_cols+n);
    time_offset = length(bigData(i).cuffdata{1,2}) - length(bigData(i).detrend_cuffdata{1,2});
    pressure_offset = bigData(i).cuffdata{1,2}(cuff_beatI(n)+time_offset);
    data = bigData(i).detrend_cuffdata{1,2}(cuff_beatI(n):cuff_beatI(n+1)) + pressure_offset;
    plot_aug_idx(data, 0.005); 
end

% end %used for 'for i = 1:length(bigData)'

% Labelling the axis with name and AIx for each pulse
function t = plot_aug_idx(pulse, dt)
    time = (0:(length(pulse)-1))*dt;
    [AI, ~, featuretimes] = analysis.AugmentationIndex(time, pulse, 'DoPlot',0);

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

        x1.FontSize = 6;
        x2.FontSize = 6;
        x3.FontSize = 6;

        t = title(['AI = ', num2str(AI)]);
    end

end

% Detect cuff pulses
function cuff_beatI = calc_cuff_beati(bigData, subject)
    sampletime = 0.004;
    osc = Oscillogram(bigData(subject).detrend_cuffdata{1,2}, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 0);
    [cuff_beatI, ~] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(bigData(subject).detrend_cuffdata{1,2}), length(bigData(subject).detrend_cuffdata{1,2})], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.05);
    %max(bigData(subject).detrend_cuffdata{1,2})

    cuff_beatI =  round(cuff_beatI); 
end

% Detect invasive aortic average 
function invasive_average = calc_invasive_average(bigData, subject)
    [beatI, ~] = analysis.BeatOnsetDetect(bigData(subject).filtered_invasivedata{1,2}, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(bigData(subject).filtered_invasivedata{1,2}), length(bigData(subject).filtered_invasivedata{1,2})], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.55);
    invasive_average = analysis.AverageBeat(bigData(subject).filtered_invasivedata{1,2}', beatI, 1, 3); % '3' can include/excule good/bad data from average calculation, 0 for no plot, 1 for show plot 
end

% Detect invasive brachial average 
function invasive_brachial_average = calc_invasive_brachial_average(bigData, subject)
    [beatI, ~] = analysis.BeatOnsetDetect(bigData(subject).filtered_invasivebrachialdata, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(bigData(subject).filtered_invasivebrachialdata), length(bigData(subject).filtered_invasivebrachialdata)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.55);
    invasive_brachial_average = analysis.AverageBeat(bigData(subject).filtered_invasivebrachialdata', beatI, 1, 3); % '3' can include/excule good/bad data from average calculation, change to 0 for no plot
end

