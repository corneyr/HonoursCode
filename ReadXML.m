function [cuffPressure,xmlData,cAveragePulse,cEstimate,cPulseStartIndexes,sSelectedPulseIndexes,cPulses,x] = ReadXML(filename)


[xmlData,cAveragePulse,cEstimate,cPulseStartIndexes,sSelectedPulseIndexes,cPulses,x] = uscom.readBPplusXml(filename);

[~,cuffPressure] = uscom.readNibpXml(filename);