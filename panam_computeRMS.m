function outputStruct = panam_computeRMS( inputStruct, field, window, visu)
%PANAM_COMPUTEPOWERTRIALS Summary of this function goes here
%   Detailed explanation goes here


outputStruct = inputStruct;

if nargin < 2 || isempty(field)
    field = 'PreProcessed';
end
if nargin < 3 
    window = 0.5;
end
if nargin < 4
   visu = 0;
end

rmsField = ['RMS_' field];


for ii = 1:length(inputStruct.Trials)
    outputStruct.Trials(ii).(rmsField) = outputStruct.Trials(ii).(field).RMS_Signal(window); 
end

if visu == 1
    panam_plotAllTrials(outputStruct, rmsField);
end