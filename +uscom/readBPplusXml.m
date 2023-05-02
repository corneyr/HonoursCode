function [xmlData,cAveragePulse,cEstimate,cPulseStartIndexes,sSelectedPulseIndexes,cPulses,x] = readBPplusXml(filename)
%readBPplusXml Read selected fields from BP+ XML measurement file
%   Read selected fields from BP+ XML measurement file:
%       cAveragePulse
%       cEstimate
%       cPulseStartIndexes
%       sSelectedPulseIndexes
%       cPulses
%       x
%
    xmlData=uscom.xml2struct(filename);
   
    % Read average central Beat
    cAveragePulse = uscom.csvTextToDoubleArray(xmlData.BPplus.Results.Result.cAveragePulse.Text);
    cEstimate = uscom.csvTextToDoubleArray(xmlData.BPplus.Results.Result.cEstimate.Text);
    cPulseStartIndexes = uscom.csvTextToIntArray(xmlData.BPplus.Results.Result.cPulseStartIndexes.Text);
    sSelectedPulseIndexes= uscom.csvTextToIntArray(xmlData.BPplus.Results.Result.sSelectedPulseIndexes.Text);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % partition detected pulses %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % cPulseStartIndexes is an array of offsets into cEstimate for the
    % start of each pulse. The differences in consecutive values is the
    % pulse length or each pulse
    
    % determine the length of the individual pulses
    pulseLengths=diff(cPulseStartIndexes);
    
    % determine the length of the longest pulse
    maxPulseLength=max(pulseLengths);
    
    numPulses=length(pulseLengths);

    cPulses = zeros(numPulses,maxPulseLength);
    for index=1:length(cPulses)
        cPulses(index)=NaN;
    end
    

    
    x = 0.0:1/200:double(maxPulseLength-1)/200.0;
  
    for index=1:numPulses
        pulse = cEstimate(cPulseStartIndexes(index):cPulseStartIndexes(index+1));
        padPulse = uscom.padArray(pulse,maxPulseLength,NaN);
        cPulses(index,:)=padPulse;
    end
  


end

