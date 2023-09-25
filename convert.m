% load('filtvsunfilt(030823).mat')

fh = fopen('C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\bigData2.csv', 'w');
fprintf(fh,['cuff_sys(1),cuff_sys(2),cuff_dia(1),cuff_dia(2),cuff_map(1),cuff_map(2),aortic_sys(1),aortic_sys(2),aortic_dia(1),aortic_dia(2),aortic_map(1),aortic_map(2),aortic_AI(1),aortic_AI(2),' ...
    'cuffbeat_close_to_sys(1),cuffbeat_close_to_sys(2),cuffbeat_close_to_dia(1),cuffbeat_close_to_dia(2),cuffbeat_close_to_map(1),cuffbeat_close_to_map(2),' ...
    'cuffAIx_at_sys(1),cuffAIx_at_sys(2),cuffAIx_at_map(1),cuffAIx_at_map(2),cuffAIx_at_dia(1),cuffAIx_at_dia(2),cuff_AIx_mean(1),cuff_AIx_mean(2),' ...
    'sbp_amp(1), sbp_amp(2), dbp_amp(1), dbp_amp(2), map_amp(1), map_amp(2),' ...
    'cuffAIx_at_AIx(1), cuffAIx_at_AIx(2), cuffidx_aorticAI_frommap(1), cuffidx_aorticAI_frommap(2),' ...
    'cuffAIx_at_AIx_brach(1),cuffAIx_at_AIx_brach(2),cuffidx_brachialAI_frommap(1),cuffidx_brachialAI_frommap(2),' ...
    'cuffAI_at_sys_brach(1), cuffAI_at_sys_brach(2), cuffAI_at_map_brach(1), cuffAI_at_map_brach(2), cuffAI_at_dia_brach(1), cuffAI_at_dia_brach(2),' ...
    'brachial_sys, brachial_dia, brachial_map,brachial_AI,cuffAI_at_sys_cuff(1),cuffAI_at_sys_cuff(2),cuffAI_at_dia_cuff(1),cuffAI_at_dia_cuff(2),cuffAI_at_map_cuff(1),cuffAI_at_map_cuff(2),' ...
    'close_to_sys_idx_cuff(1),close_to_sys_idx_cuff(2),close_to_dia_idx_cuff(1),close_to_dia_idx_cuff(2),close_to_map_idx_cuff(1),close_to_map_idx_cuff(2),' ...
    'close_to_sys_idx_brach(1),close_to_sys_idx_brach(2),close_to_dia_idx_brach(1),close_to_dia_idx_brach(2),close_to_map_idx_brach(1),close_to_map_idx_brach(2),' ...
    'total_cuffbeats(1),total_cuffbeats(2),cuffidx_aorticSYS_frommap(1),cuffidx_aorticSYS_frommap(2),cuffidx_brachialSYS_frommap(1),cuffidx_brachialSYS_frommap(2),' ...
    'cuff_sysidx_from_map(1),cuff_sysidx_from_map(2)\n']);
for i = 1:90

    cuff_sys_val = filtvsunfilt(i).cuff_sys;
    cuff_dia_val = filtvsunfilt(i).cuff_dia;
    cuff_map_val = filtvsunfilt(i).cuff_map;
    aortic_sys_val = filtvsunfilt(i).aortic_sys;
    aortic_dia_val = filtvsunfilt(i).aortic_dia;
    aortic_map_val = filtvsunfilt(i).aortic_map;
    aortic_aix_val = filtvsunfilt(i).aortic_AI;
    cuffbeat_close_to_sys = filtvsunfilt(i).close_to_sys_idx;
    cuffbeat_close_to_dia = filtvsunfilt(i).close_to_dia_idx;
    cuffbeat_close_to_map = filtvsunfilt(i).close_to_map_idx;
    cuffAIx_at_sys = filtvsunfilt(i).cuffAI_at_sys;
    cuffAIx_at_dia = filtvsunfilt(i).cuffAI_at_dia;
    cuffAIx_at_map = filtvsunfilt(i).cuffAI_at_map;
    cuff_AIx_mean = filtvsunfilt(i).cuff_AIx_mean;
    sbp_amp_val = filtvsunfilt(i).sbp_amp;
    dbp_amp_val = filtvsunfilt(i).dbp_amp;
    map_amp_val = filtvsunfilt(i).map_amp;

    AIx_of_cuffbeat_at_AIx = filtvsunfilt(i).cuffAIx_at_AIx;
    cuffbeat_at_aorticAIx = filtvsunfilt(i).cuffidx_aorticAI_frommap;
    if ~isempty(filtvsunfilt(i).min_idx_brach)
    AIx_of_cuffbeat_at_AIx_brach = filtvsunfilt(i).cuffAIx_at_AIx_brach;
    cuffbeat_at_brachialAIx = filtvsunfilt(i).cuffidx_brachialAI_frommap;
    cuffAIx_atbrach_sys = filtvsunfilt(i).cuffAI_at_sys_brach;
    cuffAIx_atbrach_map = filtvsunfilt(i).cuffAI_at_map_brach;
    cuffAIx_atbrach_dia = filtvsunfilt(i).cuffAI_at_dia_brach;
    close_to_sys_idx_brach_val = filtvsunfilt(i).close_to_sys_idx_brach;
    close_to_dia_idx_brach_val = filtvsunfilt(i).close_to_dia_idx_brach;
    close_to_map_idx_brach_val = filtvsunfilt(i).close_to_map_idx_brach;
    brachial_sys = filtvsunfilt(i).brachial_sys;
    brachial_dia = filtvsunfilt(i).brachial_dia;
    brachial_map = filtvsunfilt(i).brachial_map;
    brachial_AI = filtvsunfilt(i).brachial_AI;
    cuffidx_brachialSYS_frommap_val = filtvsunfilt(i).cuffidx_brachialSYS_frommap;

    end

    cuffAI_at_sys_cuff_val = filtvsunfilt(i).cuffAI_at_sys_cuff;
    cuffAI_at_dia_cuff_val = filtvsunfilt(i).cuffAI_at_dia_cuff;
    cuffAI_at_map_cuff_val = filtvsunfilt(i).cuffAI_at_map_cuff;

    close_to_sys_idx_cuff_val = filtvsunfilt(i).close_to_sys_idx_cuff;  
    close_to_dia_idx_cuff_val = filtvsunfilt(i).close_to_dia_idx_cuff;
    close_to_map_idx_cuff_val = filtvsunfilt(i).close_to_map_idx_cuff;
    total_cuffbeats_val = filtvsunfilt(i).total_cuffbeats;
    cuffidx_aorticSYS_frommap_val = filtvsunfilt(i).cuffidx_aorticSYS_frommap;
    cuff_sysidx_from_map_val = filtvsunfilt(i).cuff_sysidx_from_map;

      if ~isempty(cuff_sys_val) || ~isempty(aortic_sys_val) || ~isempty(filtvsunfilt(i).sbp_amp) 
          fprintf(fh,'%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n', ...
              cuff_sys_val{1},cuff_sys_val{2},cuff_dia_val{1},cuff_dia_val{2},cuff_map_val{1},cuff_map_val{2}, ...
              aortic_sys_val{1},aortic_sys_val{2},aortic_dia_val{1},aortic_dia_val{2},aortic_map_val{1},aortic_map_val{2},aortic_aix_val{1},aortic_aix_val{2}, ...
              cuffbeat_close_to_sys{1},cuffbeat_close_to_sys{2},cuffbeat_close_to_dia{1},cuffbeat_close_to_dia{2},cuffbeat_close_to_map{1}, cuffbeat_close_to_map{2}, ...
              cuffAIx_at_sys{1},cuffAIx_at_sys{2},cuffAIx_at_map{1},cuffAIx_at_map{2},cuffAIx_at_dia{1},cuffAIx_at_dia{2},cuff_AIx_mean{1},cuff_AIx_mean{2},...
              sbp_amp_val{1},sbp_amp_val{2},dbp_amp_val{1}, dbp_amp_val{2},map_amp_val{1},map_amp_val{2}, ...
              AIx_of_cuffbeat_at_AIx{1}, AIx_of_cuffbeat_at_AIx{2}, cuffbeat_at_aorticAIx{1}, cuffbeat_at_aorticAIx{2}, ...
              AIx_of_cuffbeat_at_AIx_brach{1},AIx_of_cuffbeat_at_AIx_brach{2}, cuffbeat_at_brachialAIx{1},cuffbeat_at_brachialAIx{2}, ...
              cuffAIx_atbrach_sys{1}, cuffAIx_atbrach_sys{2}, cuffAIx_atbrach_map{1}, cuffAIx_atbrach_map{2}, cuffAIx_atbrach_dia{1}, cuffAIx_atbrach_dia{2}, ...
              brachial_sys, brachial_dia, brachial_map,brachial_AI,cuffAI_at_sys_cuff_val{1},cuffAI_at_sys_cuff_val{2},cuffAI_at_dia_cuff_val{1},cuffAI_at_dia_cuff_val{2},cuffAI_at_map_cuff_val{1},cuffAI_at_map_cuff_val{2}, ...
              close_to_sys_idx_cuff_val{1},close_to_sys_idx_cuff_val{2},close_to_dia_idx_cuff_val{1},close_to_dia_idx_cuff_val{2},close_to_map_idx_cuff_val{1},close_to_map_idx_cuff_val{2}, ...
              close_to_sys_idx_brach_val{1},close_to_sys_idx_brach_val{2},close_to_dia_idx_brach_val{1},close_to_dia_idx_brach_val{2},close_to_map_idx_brach_val{1},close_to_map_idx_brach_val{2}, ...
              total_cuffbeats_val{1},total_cuffbeats_val{2},cuffidx_aorticSYS_frommap_val{1},cuffidx_aorticSYS_frommap_val{2},cuffidx_brachialSYS_frommap_val{1},cuffidx_brachialSYS_frommap_val{2}, ...
              cuff_sysidx_from_map_val{1},cuff_sysidx_from_map_val{2});
      end 
end 
fclose(fh);