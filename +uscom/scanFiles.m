files = dir('*.xml');
figNum=1;
for file = files'
    [xmlData,cAveragePulse,cEstimate,cPulseStartIndexes,sSelectedPulseIndexes,cPulses,x]=readBPplusXml(file.name);
    figure(figNum); figNum=figNum+1;
    plot(x,cPulses);
end