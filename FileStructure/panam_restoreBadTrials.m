function outputStruct = panam_restoreBadTrials(inputStruct, restoredTrials, comment )

%REMOVEBADTRIALS Restore the trials specified in restoredTrials and place them
%back into Trials category
% inputStruct : input structure of data (PANAM formatting)
% outputStruct : output structure of data (PANAM formatting)
% restoredTrials : list of trial numbers to be removed

%% checks

if ~isvector(restoredTrials) && ~isempty(restoredTrials)
    error('restoredTrials input must be a vector of trial numbers')
end
trialNums  = arrayfun(@(x) x.Raw.TrialNum, inputStruct.RemovedTrials);
if ~(length(trialNums) == length(unique(trialNums)))
    error('non-unique trial numbers in the input structure');
end
for ii = 1:length(restoredTrials)
    if isempty(find(trialNums == restoredTrials(ii), 1))
        error('some trials to be removed do not appear in the list of trial numbers');
    end
end


%% indices of the bad and good trials
indicesBad = [];
indicesGood = [];
for ii = 1:length(inputStruct.RemovedTrials)
    if any(restoredTrials == inputStruct.RemovedTrials(ii).Raw.TrialNum)
        indicesBad(end+1) = ii;
    else
        indicesGood(end+1) = ii;
    end
end

%% displace from 'trial' to 'removedTrials'
outputStruct = inputStruct;
nBadTrials = length(indicesBad);
outputStruct.Trials(end+1:end+nBadTrials) = inputStruct.RemovedTrials(indicesBad);
outputStruct.RemovedTrials = inputStruct.RemovedTrials(indicesGood);

% sort trials
[bla,orderTrials]  = sort(arrayfun(@(x) x.PreProcessed.TrialNum, outputStruct.Trials));
outputStruct.Trials = outputStruct.Trials(orderTrials);

%% update history

outputStruct.History{end+1,1} = datestr(clock);
outputStruct.History{end,2} = ['The trials whose numbers are : [' num2str(restoredTrials) '] have been restored in the Trials substructure.'];
if nargin > 2
    outputStruct.History{end+1,2} = comment;
end

