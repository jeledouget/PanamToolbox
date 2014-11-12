function outputStruct = panam_updateTrialNums(inputStruct, formerNums, newNums)

%PANAM_UPDATETRIALNUMS change trial nums -> from formerNums to newNums, e.g
%in case of missing triggers in LFP recordings
% BE CAREFUL WITH THIS FUNCTION
% WORKS IF LESS THAN 100 TRIALS


%% checkings

% formerNums and newNums must be numeric and same length
if ~isnumeric(formerNums) || ~ isnumeric(newNums)  || ~(length(formerNums)==length(newNums))
    error('formerNums and newNums arguments must be numeric and same length');
end
% unicity of the numbers in formerNums and newNums
if ~(length(formerNums) == length(unique(formerNums))) || ~(length(newNums) == length(unique(newNums)))
    error('formerNums and newNums must have unique elements');
end
% check the unicity of the trial numbers in the end
trialNumsBefore  = arrayfun(@(x) x.Raw.TrialNum, inputStruct.Trials);
if isfield(inputStruct.RemovedTrials,'Raw') && isfield(input.RemovedTrials.Raw, 'TrialNum')
    trialNumsBefore = horzcat(trialNumsBefore, arrayfun(@(x) x.Raw.TrialNum, inputStruct.RemovedTrials));
end
% trialNumsAfter + check trialNumsBefore
trialNumsAfter = trialNumsBefore; % init
for ii= 1:length(formerNums)
    index = find(trialNumsBefore == formerNums(ii));
    if isempty(index)
        error('formerNums includes trial numbers not appearing in input structure');
    end
    if length(index) > 1
        error('pb :input structure includes non-unique trial numbers');
    end
    trialNumsAfter(index) = newNums(ii);
end
% check trialNumsAfter
if ~(length(trialNumsAfter) == length(unique(trialNumsAfter)))
    error('Cannot apply new numbers:  would break the unicity of trial numbers. Check your inputs !');
end


%% change the number of trials

outputStruct = inputStruct; %init

for ii = 1:length(formerNums)
    % in Trials substructure
    index = find(arrayfun(@(x) x.Raw.TrialNum, inputStruct.Trials) == formerNums(ii));
    if ~isempty(index)
        fields = fieldnames(inputStruct.Trials);
        for field= fields'
            try
                outputStruct.Trials(index).(field{1}).TrialNum = newNums(ii);
                outputStruct.Trials(index).(field{1}).TrialName = [inputStruct.Trials(index).(field{1}).TrialName(1:end-2) num2str(newNums(ii),'%02d')];
            end
        end
    end
    
    % in RemovedTrials substructure
    if isfield(inputStruct.RemovedTrials,'Raw') && isfield(input.RemovedTrials.Raw, 'TrialNum')
        index = find(arrayfun(@(x) x.Raw.TrialNum, inputStruct.RemovedTrials) == formerNums(ii));
        if ~isempty(index)
            fields = fieldnames(inputStruct.RemovedTrials);
            for field = fields'
                try
                    outputStruct.RemovedTrials(index).(field{1}).TrialNum = newNums(ii);
                    outputStruct.RemovedTrials(index).(field{1}).TrialName = [inputStruct.RemovedTrials(index).(field{1}).TrialName(1:end-2) num2str(newNums(ii),'%02d')];
                end
            end
        end
    end
end

%% update history

outputStruct.History{end+1,1} = datestr(clock);
outputStruct.History{end,2} = ['Update of the trial numbers : trials [' num2str(formerNums) '] have been renumbered as [' num2str(newNums) '].'];


