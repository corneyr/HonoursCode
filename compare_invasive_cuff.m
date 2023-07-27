% input: bigData table from linkningxmltotxt.m
% input: getCharacteristics_redcap.m
% input: directory to data on device
% 3 lots of j = x;

for i = 1:length(bigData)
    if ~iscell(bigData(i).invasivedata) || ~iscell(bigData(i).cuffdata) 
        continue
    end 

    j = 1;



% plotting the aortic, brachial and cuff on one plot
num_cols = 5;
num_rows = ceil((length(bigData(i).cuff_beatI{1,j})-1)/num_cols)+1;

subplot(num_rows, num_cols, 1);
[t, AI_aortic] = plot_aug_idx(bigData(i).invasive_average{1,j}, 0.001, false);
t.String = "Aortic " + t.String;

if ~isempty(bigData(i).invasivebrachialdata) 
    subplot(num_rows, num_cols, num_cols);
    [t, AI_brachial] = plot_aug_idx(bigData(i).invasivebrachial_average, 0.001, false);
    t.String = "Brachial " + t.String;
end

AIx = zeros(length(bigData(i).cuff_beatI{1,j})-1, 1);
for n = 1:(length(bigData(i).cuff_beatI{1,j})-1)
    subplot(num_rows, num_cols, num_cols+n);
    time_offset = length(bigData(i).cuffdata{1,j}) - length(bigData(i).filtered_cuffdata{1,j});
    pressure_offset = bigData(i).cuffdata{1,j}(bigData(i).cuff_beatI{1,j}(n)+time_offset);
    data = bigData(i).filtered_cuffdata{1,j}(bigData(i).cuff_beatI{1,j}(n):bigData(i).cuff_beatI{1,j}(n+1)) + pressure_offset;
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

    if(subtract_flag) % detrend the cuff data
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
