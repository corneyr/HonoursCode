%ReadNibpXml
% Read NIBP Pressure Waveform from BP+ XML measurement file.
% Data is 16 bit ADC saved as base 64 encoded string.
% Function assumes first 50 vales were recorded at 0 mmHg and use the average to Auto-Zero ADC data
% Converd ADC to mmHg using value from XML.
function [xmlData,nibpPressure] = readNibpXml(filename)
    % read XML into a strucure and use "." notation to access elements
    xmlData=uscom.xml2struct(filename);
    % read scale from ADC count to mmHg on pressure Channel
    mmHgPerCountPressure=str2double(xmlData.BPplus.MeasDataLogger.mmHgPerCountPressureChannel.Text);
   
    % assumes there is only one RawCuffPressureWave in the XML
    packed_data=matlab.net.base64decode(xmlData.BPplus.MeasDataLogger.PressureWaves.RawPressureWave.RawCuffPressureWave.Text);
    nibpPressureTmp = typecast(uint8(packed_data), 'uint16');
    avgZero=mean(nibpPressureTmp(1:50));
    nibpPressureTmp = (nibpPressureTmp - avgZero);
    nibpPressure = double(nibpPressureTmp) * mmHgPerCountPressure;
end