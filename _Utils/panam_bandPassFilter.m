% PANAM_BANDPASSFILTER

% Applies band-pass filtering to all trials in the structure

% Takes a PANAM LFP-structure as input inputStruct

% Input parameters : 
    % fieldName : name of the field created in the structure
    % lowFreq : highpass frequency cut-off
    % highFreq : lowpass frequency cut-off
    % inputField (optional) : name of the trials field on which to apply band-pass filtering. Default is 'PreProcessed'
    % eraseFields (optional) : keep only new field (1) or keep old field
    % too (0). Default is 1
% Outpout : PANAM LFP-structure with band-pass field



function outputStruct = panam_bandPassFilter( inputStruct, fieldName, lowFreq, highFreq, inputField, eraseFields)

% default : inputField
if nargin < 4 || isempty(inputField)
    inputField = 'PreProcessed';
end

% default : eraseFields
if nargin < 5 || isempty(eraseFields)
    eraseFields = 1;
end

% compute the band-pass filtering
if eraseFields  
    outputStruct = rmfield(inputStruct,'Trials');
    try outputStruct = rmfield(outputStruct,'RemovedTrials');end
        
    for ii = 1:length(inputStruct.Trials)
        outputStruct.Trials(ii).(fieldName) = inputStruct.Trials(ii).(inputField).BandPassFilter(lowFreq, highFreq, 2);
    end   
else
    for ii = 1:length(inputStruct.Trials)
        inputStruct.Trials(ii).(fieldName) = inputStruct.Trials(ii).(inputField).BandPassFilter(lowFreq, highFreq, 2);
    end
    outputStruct = inputStruct;
end


end

