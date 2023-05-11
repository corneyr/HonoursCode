function plotinvasive = plot(invasivedata.Var1);

% pathway to invasive files
addpath('C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\InvasiveBP\');
% pathway to invasive files

% Plot invasive data in mmHg
readtable('100176076_22062022_cuff1_P.txt')
invasivedata = readtable('100176076_22062022_cuff1_P.txt');
plot(invasivedata.Var1);

end
