function invasivefigure = plotinvasive(path)
% pathway to invasive files


if nargin == 0
% xml files pathway
    [fn, path] = uigetfile();

    pathFile = [path fn];
else
    pathFile = path;
end
% pathway to invasive files

%filename = sprintf('%09_%08_cuff%01_P.txt');

% Plot invasive data in mmHg
readtable(pathFile);
invasivedata = readtable(pathFile);
figure()
invasivefigure = plot(invasivedata.Var1);
% drawnow



end
