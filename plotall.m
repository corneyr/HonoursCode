for i = 7%1:length(filtvsunfilt)
    if ~iscell(filtvsunfilt(i).invasivedata) || ~iscell(filtvsunfilt(i).cuffdata) 
        disp(["No Data", i,j])
        continue 
    else 
        disp(["Figure created", i j])

    end 

        j = 1;
        figure();
        subplot (3,1,1)
        plot(filtvsunfilt(i).filtered_cuffdata{1,(j)}); hold on; plot(filtvsunfilt(i).detrend_cuffdata{1,(j)});
        legend({'Cuff filtered', 'Cuff unfiltered'});
        
        subplot (3,1,2)
        plot(filtvsunfilt(i).filtered_invasivedata{1,(j)}); hold on; plot(filtvsunfilt(i).invasivedata{1,(j)});
        legend({'Aortic filtered', 'Aortic unfiltered'});
        
        subplot (3,1,3)
        plot(filtvsunfilt(i).filtered_invasivebrachialdata); hold on; plot(filtvsunfilt(i).invasivebrachialdata)
        legend({'Brachial filtered', 'Brachial unfiltered'});
    
end 