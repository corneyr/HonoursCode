% input: bigData table from linkningxmltotxt.m
% input: getCharacteristics_redcap.m
% input: directory to data on device


% for i = 1:length(bigData)
%     if ~iscell(bigData(i).invasivedata) || ~iscell(bigData(i).cuffdata) 
%         disp(["No Data", i,j])
%         continue 
%     else 
%         disp(["Figure created", i j])
% 
%     end 
    i = 3;
    j = 1;

figure();
% plotting the aortic, brachial and cuff on one plot
num_cols = 5;
num_rows = ceil((length(bigData(i).cuff_beatI{j})-1)/num_cols)+1;

sp = subplot(num_rows, num_cols, 1); 
title_handle = plot_aug_idx(bigData(i).invasive_average{j}, bigData(i).aortic_AI{j}, bigData(i).aortic_featuretimes{j}, 0.001, sp, false, false);
title_handle.String = "Aortic " + title_handle.String;

if ~isempty(bigData(i).invasivebrachialdata) 
    sp = subplot(num_rows, num_cols, num_cols);
    title_handle = plot_aug_idx(bigData(i).invasivebrachial_average, bigData(i).brachial_AI, bigData(i).brachial_featuretimes, 0.001, sp, false, false);
    title_handle.String = "Brachial " + title_handle.String;
end

%cal
time_offset = length(bigData(i).cuffdata{j}) - length(bigData(i).filtered_cuffdata{j});
[~, min_idx] = min(abs(bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}+time_offset) - bigData(i).aortic_sys{j}));

for n = 1:(length(bigData(i).cuff_beatI{j})-1)
    sp = subplot(num_rows, num_cols, num_cols+n);
    time_offset = length(bigData(i).cuffdata{j}) - length(bigData(i).filtered_cuffdata{j});
    pressure_offset = bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(n)+time_offset);
    pulse = bigData(i).filtered_cuffdata{j}(bigData(i).cuff_beatI{j}(n):bigData(i).cuff_beatI{j}(n+1)) + pressure_offset;
    plot_aug_idx(pulse, bigData(i).cuff_AIx{j}(n), bigData(i).cuff_featuretimes{j}{n}, 0.005, sp, true, n == min_idx); 
end


 %used for 'for i = 1:length(bigData)'

% Labelling the axis with name and AIx for each pulse
function title_handle = plot_aug_idx(pulse, AI, featuretimes, dt, sp, subtract_flag, bold_flag)
    time = (0:(length(pulse)-1))*dt;
    

    if(subtract_flag) % detrend the cuff data
        start_pressure = pulse(1);
        end_pressure = pulse(end);
        slope = (end_pressure - start_pressure)/max(time);
    
        line = slope * time;
        pulse = pulse - (line');
    end
    
    weight = bold_flag+1;
    plot(time, pulse, 'LineWidth', weight);
    title_handle=0;
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

        annotation('textbox','String',['AI = ', AI],'Position',sp.Position,'Vert','bottom','FitBoxToText','on')
        title_handle = title(1);
    end

end