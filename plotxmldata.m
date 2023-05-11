function plotxmldata = plot(cuffPressure);
    % finds xml data pathway
    % reads xml data 
    % plots xml data in mmHg

% xml files pathway
[fn, path] = uigetfile();
    
% Plotting the xml file
cuffPressure = xmlread([path fn], 'AllowDoctype',true);
getFirstChild(cuffPressure);
cuffPressure = ReadXML([path fn]);
plot(cuffPressure);

plotxmldata = plot(cuffPressure);
end