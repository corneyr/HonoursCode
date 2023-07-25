% input: bigData table from linkningxmltotxt.m
% input: getCharacteristics_redcap.m
% input: directory to data on device
% 3 lots of j = x;

for i = 1:length(bigData)
    if ~iscell(bigData(i).invasivedata) || ~iscell(bigData(i).cuffdata) 
        continue
    end 
    j = 2;
% Note to self, we probably want to rewrite this back into bigData at some
% point
invasive_average = calc_invasive_average(bigData, i);

if ~isempty(bigData(i).invasivebrachialdata) 
    invasive_brachial_average = calc_invasive_brachial_average(bigData, i);
end
    cuff_beatI = calc_cuff_beati(bigData, i);

% plotting the aortic, brachial and cuff on one plot
num_cols = 5;
num_rows = ceil((length(cuff_beatI)-1)/num_cols)+1;

subplot(num_rows, num_cols, 1);
[t, AI_aortic] = plot_aug_idx(invasive_average, 0.001, false);
t.String = "Aortic " + t.String;

if ~isempty(bigData(i).invasivebrachialdata) 
    subplot(num_rows, num_cols, num_cols);
    [t, AI_brachial] = plot_aug_idx(invasive_brachial_average, 0.001, false);
    t.String = "Brachial " + t.String;
end

AIx = zeros(length(cuff_beatI)-1, 1);
for n = 1:(length(cuff_beatI)-1)
    subplot(num_rows, num_cols, num_cols+n);
    disp(num_cols+n)
    time_offset = length(bigData(i).cuffdata{1,(j)}) - length(bigData(i).filtered_cuffdata{1,(j)});
    pressure_offset = bigData(i).cuffdata{1,(j)}(cuff_beatI(n)+time_offset);
    data = bigData(i).filtered_cuffdata{1,(j)}(cuff_beatI(n):cuff_beatI(n+1)) + pressure_offset;
    [~, AIx(n)] = plot_aug_idx(data, 0.005, true); 
end

bigData(i).AI_aortic{j} = AI_aortic;
bigData(i).AI_brachial = AI_brachial;
bigData(i).AIx{j} = AIx;

end %used for 'for i = 1:length(bigData)'

% Labelling the axis with name and AIx for each pulse
function [t, AI] = plot_aug_idx(pulse, dt, subtract_flag)
    time = (0:(length(pulse)-1))*dt;
    [AI, ~, featuretimes] = analysis.AugmentationIndex(time, pulse, 'DoPlot',0);

    if(subtract_flag)
        start_pressure = pulse(1);
        end_pressure = pulse(end);
        slope = (end_pressure - start_pressure)/max(time);
    
        line = slope * time;
        pulse = pulse - (line');
    end

    plot(time, pulse);
    t=0;
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
    j = 2;
    sampletime = 0.004;
    osc = Oscillogram(bigData(subject).filtered_cuffdata{1,(j)}, sampletime, 'BaselineSmoothTime', 4, 'OscillogramSmoothTime', 0.2, 'Plot', 0);
    [cuff_beatI, ~] = analysis.BeatOnsetDetect(osc, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(bigData(subject).filtered_cuffdata{1,(j)}), length(bigData(subject).filtered_cuffdata{1,(j)})], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.05);
    cuff_beatI =  round(cuff_beatI); 
end

% Detect invasive aortic average 
function invasive_average = calc_invasive_average(bigData, subject)
    j = 2;
    [beatI, ~] = analysis.BeatOnsetDetect(bigData(subject).filtered_invasivedata{1,(j)}, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(bigData(subject).filtered_invasivedata{1,(j)}), length(bigData(subject).filtered_invasivedata{1,(j)})], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.55);
    invasive_average = analysis.AverageBeat(bigData(subject).filtered_invasivedata{1,(j)}', beatI, 1, 3); % '3' can include/excule good/bad data from average calculation, 0 for no plot, 1 for show plot 
end

% Detect invasive brachial average 
function invasive_brachial_average = calc_invasive_brachial_average(bigData, subject)
    [beatI, ~] = analysis.BeatOnsetDetect(bigData(subject).filtered_invasivebrachialdata, 'Method', 'GradientIntersection', 'Interactive', 1,'RegionLimits', [max(bigData(subject).filtered_invasivebrachialdata), length(bigData(subject).filtered_invasivebrachialdata)], 'MinimumThreshold', 0.1, 'DerivativePeakThreshold', 0.55);
    invasive_brachial_average = analysis.AverageBeat(bigData(subject).filtered_invasivebrachialdata', beatI, 1, 3); % '3' can include/excule good/bad data from average calculation, change to 0 for no plot
end
