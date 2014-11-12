function outputStruct = panam_supressTriggers( inputStruct, triggerNums )
%PANAM_SUPRESSTRIALS : suppress definitely triggers without them going to
%RemovedTrials substructure. Necessary for example when a trigger LFP is
%BAD.
% NEED TO BE CAREFUL : the suppressed triggers are identified with the trial
% names in the LFP input data structure

%% check triggerNums

% structure
if ~isvector(triggerNums)
    error('triggerNums input must be a vector of trial numbers')
end
allTrialNums  = arrayfun(@(x) x.Raw.TrialNum, inputStruct.Trials);
if isfield(inputStruct.RemovedTrials,'Raw') && isfield(input.RemovedTrials.Raw, 'TrialNum')
    allTrialNums = horzcat(allTrialNums, arrayfun(@(x) x.Raw.TrialNum, inputStruct.RemovedTrials));
end
if ~(length(allTrialNums) == length(unique(allTrialNums)))
    error('non-unique trigger numbers in the input structure');
end
for ii = 1:length(triggerNums)
    if isempty(find(allTrialNums == triggerNums(ii), 1))
        error('some triggers to be suppressed do not appear in the list of trigger numbers');
    end
end

%% suppress triggers

indexKeptTrials = [];
for ii = 1:length(inputStruct.Trials)
    if ~any(triggerNums == inputStruct.Trials(ii).Raw.TrialNum)
        indexKeptTrials(end+1) = ii;
    end
end

outputStruct = inputStruct;
outputStruct.Trials = inputStruct.Trials(indexKeptTrials);

if isfield(inputStruct.RemovedTrials,'Raw') && isfield(input.RemovedTrials.Raw, 'TrialNum')
    indexKeptTrials = [];
    for ii = 1:length(inputStruct.RemovedTrials)
        if ~any(triggerNums == inputStrut.RemovedTrials(ii).Raw.TrialNum)
            indexKeptTrials(end+1) = ii;
        end
    end
    outputStruct.RemovedTrials = inputStruct.RemovedTrials(indexKeptTrials);
end

%% update history

outputStruct.History{end+1,1} = datestr(clock);
outputStruct.History{end,2} = ['Definitive suppression of the triggers whose numbers are : [' num2str(triggerNums) '].'];

