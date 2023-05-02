function [data] = csvTextToIntArray(csvText)
%csvTextToDoubleArray textscan csv string and return array of doubles
%   Input string is a comma separated list of double values that is scanned
%   and returned as an array of doubles.
csvValues = textscan(csvText,'%u','Delimiter',',');
csvStruct = cell2struct(csvValues, 'values', 1);
data = transpose(csvStruct.values);
end

