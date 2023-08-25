% input: bigData table from linkningxmltotxt.m
% input: getCharacteristics_redcap.m
% input: directory to data on device
% input: getXMLfile.m

%  get xml file pathway and name
% [xml_data, xml_path, full_xml_data] = getXMLfile(file_index, toppath);

% This function improts data from characteristics_redcap file 
% Finds coloums with BPplus file names, THCI, and Date of study 
characteristicsredcap = getCharacteristics_redcap();

% get xml name from files csv file
% bigdata is finding the xml and txt file names from the redcap csv file.
% detrends cuff data
% filters cuff and invasive data
% determines beat indicies of cuff and invasive data 
% determines Sys, Dia, and MAP of cuff and invasive data
bigData = linkingxmltotxt();


% script: compare_invasive_cuff.m
% plot individual cuff pulses and average invasive waveforms with AIx

for i = 1:length(bigData)
    if ~iscell(bigData(i).invasivedata) || ~iscell(bigData(i).cuffdata) 
        disp(["No Data", i,j])
        continue 
    else 
        disp(["Figure created", i j])

    end 
    j = 2;


    % figure();
    % plotting the aortic, brachial and cuff on one plot
    num_cols = 5;
    num_rows = ceil((length(bigData(i).cuff_beatI{j})-1)/num_cols)+1;
    
    sp = subplot(num_rows, num_cols, 1); 
    title_handle = plot_aug_idx(bigData(i).invasive_average{j}, bigData(i).aortic_AI{j}, bigData(i).aortic_featuretimes{j}, 0.001, sp, "Aortic Pressure", false, false);
    
    if ~isempty(bigData(i).invasivebrachialdata) 
        sp = subplot(num_rows, num_cols, num_cols);
        title_handle = plot_aug_idx(bigData(i).invasivebrachial_average, bigData(i).brachial_AI, bigData(i).brachial_featuretimes, 0.001, sp, "Brachial Pressure", false, false);
    end
    
    %calculate idx of pulse whose start pressure is closest to aortic
    %systolic_pressure
    time_offset = length(bigData(i).cuffdata{j}) - length(bigData(i).filtered_cuffdata{j});
    [~, bigData(i).close_to_sys_idx{j}] = min(abs(bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(1:end-1)+time_offset) - bigData(i).aortic_sys{j}));
    [~, bigData(i).close_to_map_idx{j}] = min(abs(bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(1:end-1)+time_offset) - bigData(i).aortic_map{j}));
    [~, bigData(i).close_to_dia_idx{j}] = min(abs(bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(1:end-1)+time_offset) - bigData(i).aortic_dia{j}));
        %brachial
    if ~isempty(bigData(i).invasivebrachialdata) 
        [~, bigData(i).close_to_sys_idx_brach{j}] = min(abs(bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(1:end-1)+time_offset) - bigData(i).brachial_sys));
        [~, bigData(i).close_to_map_idx_brach{j}] = min(abs(bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(1:end-1)+time_offset) - bigData(i).brachial_map));
        [~, bigData(i).close_to_dia_idx_brach{j}] = min(abs(bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(1:end-1)+time_offset) - bigData(i).brachial_dia));
    end
        %cuff
    if iscell(bigData(i).cuffdata)
        [~, bigData(i).close_to_sys_idx_cuff{j}] = min(abs(bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(1:end-1)+time_offset) - bigData(i).cuff_sys{j}));
        [~, bigData(i).close_to_map_idx_cuff{j}] = min(abs(bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(1:end-1)+time_offset) - bigData(i).cuff_map{j}));
        [~, bigData(i).close_to_dia_idx_cuff{j}] = min(abs(bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(1:end-1)+time_offset) - bigData(i).cuff_dia{j}));
    end


    %finding the AIx of the cuff beat found at the found sys, map and dia
    bigData(i).cuffAI_at_sys{j} = bigData(i).cuff_AIx{j}( bigData(i).close_to_sys_idx{j} );
    bigData(i).cuffAI_at_map{j} = bigData(i).cuff_AIx{j}( bigData(i).close_to_map_idx{j} );
    bigData(i).cuffAI_at_dia{j} = bigData(i).cuff_AIx{j}( bigData(i).close_to_dia_idx{j} );
        %brachial
    if ~isempty(bigData(i).invasivebrachialdata) 
        bigData(i).cuffAI_at_sys_brach{j} = bigData(i).cuff_AIx{j}( bigData(i).close_to_sys_idx_brach{j} );
        bigData(i).cuffAI_at_map_brach{j} = bigData(i).cuff_AIx{j}( bigData(i).close_to_map_idx_brach{j} );
        bigData(i).cuffAI_at_dia_brach{j} = bigData(i).cuff_AIx{j}( bigData(i).close_to_dia_idx_brach{j} );
    end
        %cuff
    if iscell(bigData(i).cuffdata)
        bigData(i).cuffAI_at_sys_cuff{j} = bigData(i).cuff_AIx{j}( bigData(i).close_to_sys_idx_cuff{j} );
        bigData(i).cuffAI_at_map_cuff{j} = bigData(i).cuff_AIx{j}( bigData(i).close_to_map_idx_cuff{j} );
        bigData(i).cuffAI_at_dia_cuff{j} = bigData(i).cuff_AIx{j}( bigData(i).close_to_dia_idx_cuff{j} );   
    end

    lower_step_size = 1/(bigData(i).close_to_map_idx{j} - bigData(i).close_to_sys_idx{j});
    upper_step_size = 1/(bigData(i).close_to_dia_idx{j} - bigData(i).close_to_map_idx{j});
    
    for n = 1:(length(bigData(i).cuff_beatI{j})-1)
        sp = subplot(num_rows, num_cols, num_cols+n);
        time_offset = length(bigData(i).cuffdata{j}) - length(bigData(i).filtered_cuffdata{j});
        pressure_offset = bigData(i).cuffdata{j}(bigData(i).cuff_beatI{j}(n)+time_offset);
        filtered_pulse = bigData(i).filtered_cuffdata{j}(bigData(i).cuff_beatI{j}(n):bigData(i).cuff_beatI{j}(n+1));
        pulse =  filtered_pulse - filtered_pulse(1) + pressure_offset;
        if n == bigData(i).close_to_sys_idx{j} || n == bigData(i).close_to_map_idx{j} || n == bigData(i).close_to_dia_idx{j}
            bolded = true;
        else
            bolded = false;
        end
        
        if n <= bigData(i).close_to_map_idx{j}
            pressure_phase_idx = -1 + lower_step_size*(n - bigData(i).close_to_sys_idx{j});
        else 
            pressure_phase_idx = upper_step_size*(n - bigData(i).close_to_map_idx{j});
        end
        plot_aug_idx(pulse, bigData(i).cuff_AIx{j}(n), bigData(i).cuff_featuretimes{j}{n}, 0.005, sp, pressure_phase_idx, true, bolded); 
         
        % finding the cuff beat which has the closest AIx to the aortic AIx
        [~, bigData(i).min_idx{j}] = min(abs(bigData(i).cuff_AIx{j} - bigData(i).aortic_AI{j}));
        bigData(i).cuffidx_aorticAI_frommap{j} = (bigData(i).close_to_map_idx{j} - bigData(i).min_idx{j});
        %brachial
        if ~isempty(bigData(i).invasivebrachialdata) 
            [~, bigData(i).min_idx_brach{j}] = min(abs(bigData(i).cuff_AIx{j} - bigData(i).brachial_AI));
            bigData(i).cuffidx_brachialAI_frommap{j} = (bigData(i).close_to_map_idx_brach{j} - bigData(i).min_idx_brach{j});
        end


        %finding the amplification from aortic to brachial 
        bigData(i).sbp_amp{j} = bigData(i).brachial_sys - bigData(i).aortic_sys{j};
        bigData(i).dbp_amp{j} = bigData(i).brachial_dia - bigData(i).aortic_dia{j};
        bigData(i).map_amp{j} = bigData(i).brachial_map - bigData(i).aortic_map{j};


        %finding the AIx of the cuff beat found at aortic aix
        bigData(i).cuffAIx_at_AIx{j} = bigData(i).cuff_AIx{j}(bigData(i).min_idx{j});
        %brachial
        if ~isempty(bigData(i).invasivebrachialdata) 
            bigData(i).cuffAIx_at_AIx_brach{j} = bigData(i).cuff_AIx{j}(bigData(i).min_idx_brach{j});
        end

    end
end %used for 'for i = 1:length(bigData)'

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
