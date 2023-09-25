% input: filtvsunfilt table from linkningxmltotxt.m
% input: getCharacteristics_redcap.m
% input: directory to data on device

for i = 1%:length(filtvsunfilt)
    if ~iscell(filtvsunfilt(i).invasivedata) || ~iscell(filtvsunfilt(i).cuffdata) 
        disp(["No Data", i,j])
        continue 
    else 
        disp(["Figure created", i j])
   
    end 
    j = 1;


    figure();
    % plotting the aortic, brachial and cuff on one plot
    num_cols = 5;
    num_rows = ceil((length(filtvsunfilt(i).cuff_beatI{j})-1)/num_cols)+1;
    
    sp = subplot(num_rows, num_cols, 1); 
    title_handle = plot_aug_idx(filtvsunfilt(i).invasive_average{j}, filtvsunfilt(i).aortic_AI{j}, filtvsunfilt(i).aortic_featuretimes{j}, 0.001, sp, "Aortic Pressure", false, false);
    
    if ~isempty(filtvsunfilt(i).invasivebrachialdata) 
        sp = subplot(num_rows, num_cols, num_cols);
        title_handle = plot_aug_idx(filtvsunfilt(i).invasivebrachial_average, filtvsunfilt(i).brachial_AI, filtvsunfilt(i).brachial_featuretimes, 0.001, sp, "Brachial Pressure", false, false);
    end
    
    %calculate idx of pulse whose start pressure is closest to aortic
    %systolic_pressure
    time_offset = length(filtvsunfilt(i).cuffdata{j}) - length(filtvsunfilt(i).filtered_cuffdata{j});
    [~, filtvsunfilt(i).close_to_sys_idx{j}] = min(abs(filtvsunfilt(i).cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(1:end-1)+time_offset) - filtvsunfilt(i).aortic_sys{j}));
    [~, filtvsunfilt(i).close_to_map_idx{j}] = min(abs(filtvsunfilt(i).cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(1:end-1)+time_offset) - filtvsunfilt(i).aortic_map{j}));
    [~, filtvsunfilt(i).close_to_dia_idx{j}] = min(abs(filtvsunfilt(i).cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(1:end-1)+time_offset) - filtvsunfilt(i).aortic_dia{j}));
        %brachial
    if ~isempty(filtvsunfilt(i).invasivebrachialdata) 
        [~, filtvsunfilt(i).close_to_sys_idx_brach{j}] = min(abs(filtvsunfilt(i).cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(1:end-1)+time_offset) - filtvsunfilt(i).brachial_sys));
        [~, filtvsunfilt(i).close_to_map_idx_brach{j}] = min(abs(filtvsunfilt(i).cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(1:end-1)+time_offset) - filtvsunfilt(i).brachial_map));
        [~, filtvsunfilt(i).close_to_dia_idx_brach{j}] = min(abs(filtvsunfilt(i).cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(1:end-1)+time_offset) - filtvsunfilt(i).brachial_dia));
    end
        %cuff
    if iscell(filtvsunfilt(i).cuffdata)
        [~, filtvsunfilt(i).close_to_sys_idx_cuff{j}] = min(abs(filtvsunfilt(i).cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(1:end-1)+time_offset) - filtvsunfilt(i).cuff_sys{j}));
        [~, filtvsunfilt(i).close_to_map_idx_cuff{j}] = min(abs(filtvsunfilt(i).cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(1:end-1)+time_offset) - filtvsunfilt(i).cuff_map{j}));
        [~, filtvsunfilt(i).close_to_dia_idx_cuff{j}] = min(abs(filtvsunfilt(i).cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(1:end-1)+time_offset) - filtvsunfilt(i).cuff_dia{j}));
    end


    %finding the AIx of the cuff beat found at the found sys, map and dia
    filtvsunfilt(i).cuffAI_at_sys{j} = filtvsunfilt(i).cuff_AIx{j}( filtvsunfilt(i).close_to_sys_idx{j} );
    filtvsunfilt(i).cuffAI_at_map{j} = filtvsunfilt(i).cuff_AIx{j}( filtvsunfilt(i).close_to_map_idx{j} );
    filtvsunfilt(i).cuffAI_at_dia{j} = filtvsunfilt(i).cuff_AIx{j}( filtvsunfilt(i).close_to_dia_idx{j} );
        %brachial
    if ~isempty(filtvsunfilt(i).invasivebrachialdata) 
        filtvsunfilt(i).cuffAI_at_sys_brach{j} = filtvsunfilt(i).cuff_AIx{j}( filtvsunfilt(i).close_to_sys_idx_brach{j} );
        filtvsunfilt(i).cuffAI_at_map_brach{j} = filtvsunfilt(i).cuff_AIx{j}( filtvsunfilt(i).close_to_map_idx_brach{j} );
        filtvsunfilt(i).cuffAI_at_dia_brach{j} = filtvsunfilt(i).cuff_AIx{j}( filtvsunfilt(i).close_to_dia_idx_brach{j} );
    end
        %cuff
    if iscell(filtvsunfilt(i).cuffdata)
        filtvsunfilt(i).cuffAI_at_sys_cuff{j} = filtvsunfilt(i).cuff_AIx{j}( filtvsunfilt(i).close_to_sys_idx_cuff{j} );
        filtvsunfilt(i).cuffAI_at_map_cuff{j} = filtvsunfilt(i).cuff_AIx{j}( filtvsunfilt(i).close_to_map_idx_cuff{j} );
        filtvsunfilt(i).cuffAI_at_dia_cuff{j} = filtvsunfilt(i).cuff_AIx{j}( filtvsunfilt(i).close_to_dia_idx_cuff{j} );   
    end

    lower_step_size = 1/(filtvsunfilt(i).close_to_map_idx{j} - filtvsunfilt(i).close_to_sys_idx{j});
    upper_step_size = 1/(filtvsunfilt(i).close_to_dia_idx{j} - filtvsunfilt(i).close_to_map_idx{j});
    
    for n = 1:(length(filtvsunfilt(i).cuff_beatI{j})-1)
        sp = subplot(num_rows, num_cols, num_cols+n);
        time_offset = length(filtvsunfilt(i).cuffdata{j}) - length(filtvsunfilt(i).filtered_cuffdata{j});
        pressure_offset = filtvsunfilt(i).cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(n)+time_offset);
        filtered_pulse = filtvsunfilt(i).filtered_cuffdata{j}(filtvsunfilt(i).cuff_beatI{j}(n):filtvsunfilt(i).cuff_beatI{j}(n+1));
        pulse =  filtered_pulse - filtered_pulse(1) + pressure_offset;
        if n == filtvsunfilt(i).close_to_sys_idx{j} || n == filtvsunfilt(i).close_to_map_idx{j} || n == filtvsunfilt(i).close_to_dia_idx{j}
            bolded = true;
        else
            bolded = false;
        end
        
        if n <= filtvsunfilt(i).close_to_map_idx{j}
            pressure_phase_idx = -1 + lower_step_size*(n - filtvsunfilt(i).close_to_sys_idx{j});
        else 
            pressure_phase_idx = upper_step_size*(n - filtvsunfilt(i).close_to_map_idx{j});
        end
        plot_aug_idx(pulse, filtvsunfilt(i).cuff_AIx{j}(n), filtvsunfilt(i).cuff_featuretimes{j}{n}, 0.005, sp, pressure_phase_idx, true, bolded); 
         
        % finding the cuff beat which has the closest AIx to the aortic AIx
        [~, filtvsunfilt(i).min_idx{j}] = min(abs(filtvsunfilt(i).cuff_AIx{j} - filtvsunfilt(i).aortic_AI{j}));
        filtvsunfilt(i).cuffidx_aorticAI_frommap{j} = (filtvsunfilt(i).close_to_map_idx_cuff{j} - filtvsunfilt(i).min_idx{j});
        %brachial
        if ~isempty(filtvsunfilt(i).invasivebrachialdata) 
            [~, filtvsunfilt(i).min_idx_brach{j}] = min(abs(filtvsunfilt(i).cuff_AIx{j} - filtvsunfilt(i).brachial_AI));
            filtvsunfilt(i).cuffidx_brachialAI_frommap{j} = (filtvsunfilt(i).close_to_map_idx_cuff{j} - filtvsunfilt(i).min_idx_brach{j});
        end
    
        % finding the cuff beat which has the closest AIx to the aortic SYS
        filtvsunfilt(i).cuffidx_aorticSYS_frommap{j} = (filtvsunfilt(i).close_to_map_idx_cuff{j}-filtvsunfilt(i).close_to_sys_idx{j});
        %brachial
        if ~isempty(filtvsunfilt(i).invasivebrachialdata) 
        filtvsunfilt(i).cuffidx_brachialSYS_frommap{j} = (filtvsunfilt(i).close_to_map_idx_cuff{j}-filtvsunfilt(i).close_to_sys_idx_brach{j});
        end        

        %finding the amplification from aortic to brachial 
        filtvsunfilt(i).sbp_amp{j} = filtvsunfilt(i).brachial_sys - filtvsunfilt(i).aortic_sys{j};
        filtvsunfilt(i).dbp_amp{j} = filtvsunfilt(i).brachial_dia - filtvsunfilt(i).aortic_dia{j};
        filtvsunfilt(i).map_amp{j} = filtvsunfilt(i).brachial_map - filtvsunfilt(i).aortic_map{j};


        %finding the AIx of the cuff beat found at aortic aix
        filtvsunfilt(i).cuffAIx_at_AIx{j} = filtvsunfilt(i).cuff_AIx{j}(filtvsunfilt(i).min_idx{j});
        %brachial
        if ~isempty(filtvsunfilt(i).invasivebrachialdata) 
            filtvsunfilt(i).cuffAIx_at_AIx_brach{j} = filtvsunfilt(i).cuff_AIx{j}(filtvsunfilt(i).min_idx_brach{j});
        end

        %Finding the average AIx of each cuff deflation curve 
        if ~isempty(filtvsunfilt(i).cuff_AIx)
        filtvsunfilt(i).cuff_AIx_mean{j} = mean(filtvsunfilt(i).cuff_AIx{j}, 'omitnan');
        end

        %finding the total number of cuff beats 
        if ~isempty(filtvsunfilt(i).cuff_AIx)
        filtvsunfilt(i).total_cuffbeats{j} = height(filtvsunfilt(i).cuff_AIx{j});
        end

        %Finding the beat index of cuff SBP beat from cuff MAP
        filtvsunfilt(i).cuff_sysidx_from_map{j} = filtvsunfilt(i).close_to_map_idx_cuff{j}-filtvsunfilt(i).close_to_sys_idx_cuff{j};


       
    end
end %used for 'for i = 1:length(filtvsunfilt)'

% Labelling the axis with name and AIx for each pulse
function title_handle = plot_aug_idx(pulse, AI, featuretimes, dt, sp, title_str, subtract_flag, bold_flag)
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
        x2 = xline( featuretimes.inflection,'-','Inflection');

        x1.LabelVerticalAlignment = 'middle';
        x1.LabelHorizontalAlignment = 'center';

        x2.LabelVerticalAlignment = 'middle';
        x2.LabelHorizontalAlignment = 'center';

        x1.FontSize = 6;
        x2.FontSize = 6;

        annotation('textbox','String',['AI = ', num2str(AI, '%.1f')],'Position', sp.Position,'HorizontalAlignment','right', 'vert', 'middle', 'FitBoxToText','on', 'FontSize', 6, 'margin', 2, 'linestyle', 'none')
        title_handle = title(num2str(title_str, '%.3f'));
    end
    limits = ylim();
    new_limits = [floor(limits(1)), ceil(limits(2))];
    ylim(new_limits);
    yticks(new_limits);
       
end