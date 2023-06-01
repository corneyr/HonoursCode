function invasivecufffigure = plotcuffandinvasive()
% plotting the cuff and invasive data together 

%for measurement 1
subplot(2,1,1);
plot(bigData(1).invasivedata{1});
subplot(2,1,2);
plot(bigData(2).cuffdata{1});


%for measurement 2
subplot(2,1,1);
plot(bigData(1).invasivedata{2});
subplot(2,1,2);
plot(bigData(1).cuffdata{2});


% with parameters 
figure()
subplot (2,1,1);
plot(diff(bigData(18).cuffdata{1,1}(1890:6290)))
subplot (2,1,2);
plot(bigData(18).invasivedata{1,1});



   