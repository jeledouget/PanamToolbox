function outputStruct = panam_removeBadTrials(inputStruct, badTrials )

%REMOVEBADTRIALS Remove the trials specified in badTrials and place them
%into RemovedTrials category
% inputStruct : input structure of data (PANAM formatting)
% outputStruct : output structure of data (PANAM formatting)
% badTrials : list of trial numbers to be removed

%% checks

if ~isvector(badTrials) && ~isempty(badTrials)
    error('badTrials input must be a vector of trial numbers')
end
trialNums  = arrayfun(@(x) x.Raw.TrialNum, inputStruct.Trials);
if ~(length(trialNums) == length(unique(trialNums)))
    error('non-unique trial numbers in the input structure');
end
for ii = 1:length(badTrials)
    if isempty(find(trialNums == badTrials(ii), 1))
        error('some trials to be removed do not appear in the list of trial numbers');
    end
end


%% indices of the bad and good trials
indicesBad = [];
indicesGood = [];
for ii = 1:length(inputStruct.Trials)
    if any(badTrials == inputStruct.Trials(ii).Raw.TrialNum)
        indicesBad(end+1) = ii;
    else
        indicesGood(end+1) = ii;
    end
end

%% displace from 'trial' to 'removedTrials'
outputStruct = inputStruct;
nBadTrials = length(indicesBad);
if isempty(outputStruct.RemovedTrials)
    outputStruct.RemovedTrials = inputStruct.Trials(indicesBad);
else
    outputStruct.RemovedTrials(end+1:end+nBadTrials) = inputStruct.Trials(indicesBad);
end
outputStruct.Trials = inputStruct.Trials(indicesGood);

%% update history

outputStruct.History{end+1,1} = datestr(clock);
outputStruct.History{end,2} = ['The trials whose numbers are : [' num2str(badTrials) '] have been placed in the RemovedTrials substructure.'];

end

