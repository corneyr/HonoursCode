function plot_examples(filtertype, runs)
% This is a quick script to plot some waveforms with two types of filtering
% Use filtertype = 1 for whatever is in bigData(runs(i)).filtered_invasivedata{1,2}
% Use filtertype = 2 for a SavGol smoothing filtering, span 121, polynomial order 2 (default)
% e.g. runs = [1,2,3]
% After running this, you need to manually zoom in to see one beat for each plot (quick and dirty code)


load('bigData.mat', 'bigData');

figure;
set(gcf, 'position', [28         349        1827         406]);

for i= 1:length(runs)
    subplot(1,length(runs),i);
    hold on
    if ~isempty(bigData(runs(i)).invasivedata)
        plot(bigData(runs(i)).invasivedata{1,2});
        if filtertype == 1
            plot(bigData(runs(i)).filtered_invasivedata{1,2});
        end
        if filtertype == 2
            sm = smooth(bigData(runs(i)).invasivedata{1,2}, 121, 'sgolay');
            plot(sm);
        end
        legend({'unfiltered', 'filtered'});
        title(sprintf('i = %g', runs(i)));
    end
end