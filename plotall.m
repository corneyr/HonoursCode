i = 26; %not done
j = 1;
subplot (3,1,1)
plot(bigData(i).filtered_cuffdata{1,(j)}); hold on; plot(bigData(i).detrend_cuffdata{1,(j)});
legend({'Cuff filtered', 'Cuff unfiltered'});
subplot (3,1,2)
plot(smooth(bigData(i).invasivedata{1,(j)}, 121, 'sgolay')); hold on; plot(bigData(i).invasivedata{1,(j)});
legend({'Aortic filtered', 'Aortic unfiltered'});
subplot (3,1,3)
plot(smooth(bigData(i).invasivebrachialdata, 121, 'sgolay')); hold on; plot(bigData(i).invasivebrachialdata)
legend({'Brachial filtered', 'Brachial unfiltered'});

