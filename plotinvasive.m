function invasivefigure = plotinvasive(path_file)
% pathway to invasive files
if ~exist('pathdef', 'var')
    path_file = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\InvasiveBP\';
end

% pathway to invasive files

%filename = sprintf('%09_%08_cuff%01_P.txt');

% Plot invasive data in mmHg
%readtable('100176076_22062022_cuff1_P.txt')
invasivedata = readtable(path_file);
plot(invasivedata.Var1);

invasivefigure = plot(invasivedata.Var1);

end
