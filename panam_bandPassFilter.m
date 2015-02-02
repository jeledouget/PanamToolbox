function outputStruct = panam_bandPassFilter( inputStruct, fieldName, lowFreq, highFreq )
%PANAM_BANDPASSFILTER Summary of this function goes here
%   Detailed explanation goes here



for ii = 1:length(inputStruct.Trials)
    inputStruct.Trials(ii).(fieldName) = inputStruct.Trials(ii).PreProcessed.BandPassFilter(lowFreq, highFreq, 2);
end

outputStruct = inputStruct;

end

