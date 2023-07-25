for i = 1:length(bigData)
    if ~iscell(bigData(i).invasivedata) || ~iscell(bigData(i).cuffdata) 
        continue
    end 
        j = 2;
        subplot (3,1,1)
        plot(smooth(bigData(i).detrend_cuffdata{j}, 10, 'sgolay')); hold on; plot(bigData(i).detrend_cuffdata{1,(j)});
        legend({'Cuff filtered', 'Cuff unfiltered'});
        
        subplot (3,1,2)
        plot(smooth(bigData(i).invasivedata{1,(j)}, 121, 'sgolay')); hold on; plot(bigData(i).invasivedata{1,(j)});
        bigData(i).filtered_maxinvasiveindicies{j} = max(smooth(bigData(i).invasivedata{1,(j)}, 121, 'sgolay'));
        bigData(i).unfiltered_maxinvasiveindicies{j} = max(bigData(i).invasivedata{1,(j)});
        bigData(i).filtered_mininvasiveindicies{j} = min(smooth(bigData(i).invasivedata{1,(j)}, 121, 'sgolay'));
        bigData(i).unfiltered_mininvasiveindicies{j} = min(bigData(i).invasivedata{1,(j)});
        legend({'Aortic filtered', 'Aortic unfiltered'});
        
        subplot (3,1,3)
        plot(smooth(bigData(i).invasivebrachialdata, 121, 'sgolay')); hold on; plot(bigData(i).invasivebrachialdata)
        bigData(i).filtered_maxinvasivebrachialindicies = max(smooth(bigData(i).invasivebrachialdata, 121, 'sgolay'));
        bigData(i).unfiltered_maxinvasivebrachialindicies = max(bigData(i).invasivebrachialdata);
        bigData(i).filtered_mininvasivebrachialindicies = min(smooth(bigData(i).invasivebrachialdata, 121, 'sgolay'));
        bigData(i).unfiltered_mininvasivebrachialindicies = min(bigData(i).invasivebrachialdata);
        legend({'Brachial filtered', 'Brachial unfiltered'});

end 