function outputStruct = panam_timeFrequencyProcess( inputStructs, inputEvents, param )

%PANAM_TIMEFREQUENCYPROCESS Function to compute corrections and averages on
%Panam TimeFrequency structures

% inputStructs :
% must be a structure with field files : string or a cell array of
% strings (files addresses, partial or full), and with field path : folder in which to
% find the files (will be concatenated with the file address)
% OR a structure with field structures : PANAM_TIMEFREQUENCY structure or
% PANAM_TIMEFREQUENCY structure cell array
% Possible to mix both inputs but not recommended
% (OPTIONAL) inputEvents
% same as inputStructs but with PANAM_TRIALPARAMS as structure instead
% of PANAM_TIMEFREQUENCY
% (OPTIONAL) param:
% structure of parameters for the TIMEFREQUENCY preocessing operation


%% default parameters
% define the default parameters


%% check/affect parameters


%% check the format of input files and input events structures, and prepare for loading the data
% input files
if isfield(inputStructs,'files')
    if isempty(inputStructs.files)
        inputStructs = rmfield(inputStructs,'files');
    else % non-empty
        % one input as a string
        if ischar(inputStructs.files)
            inputStructs.files = {inputStructs.files};
        end
        if ~iscell(inputStructs.files) || ~all(cellfun(@ischar,inputStructs.files))
            error('''files'' field must be a string or cell array of strings');
        end
        % path
        if isfield(inputStructs,'path')
            if ischar(inputStructs.path)
                inputStructs.files = cellfun(@fullfile, ...
                    repmat({inputStructs.path},[1 length(inputStructs.files)]),inputStructs.files,'UniformOutput',0);
            else
                error('''path'' field in inputStructs must be a string indicating the common origin folder of the inputStruct files');
            end
        end
    end
end
% events
if nargin > 1
    if isempty(inputEvents)
        inputEvents = {};
        warning('no TrialParams have been input, therefore no events information : trials will be aligned with the trigger');
    end
    if isfield(inputEvents,'files')
        if isempty(inputEvents.files)
            inputEvents = rmfield(inputEvents,'files');
        else % non-empty
            % one input as a string
            if ischar(inputEvents.files)
                inputEvents.files = {inputEvents.files};
            end
            if ~iscell(inputEvents.files) || ~all(cellfun(@ischar,inputStructs.files))
                error('''files'' field must be a string or cell array of strings');
            end
            % path
            if isfield(inputEvents,'path')
                if ischar(inputEvents.path)
                    inputEvents.files = cellfun(@fullfile, ...
                        repmat({inputEvents.path},[1 length(inputEvents.files)]),inputEvents.files,'UniformOutput',0);
                else
                    error('''path'' field in inputEvents must be a string indicating the common origin folder of the inputStruct files');
                end
            end
        end
    end
else
    inputEvents = {};
    warning('no TrialParams have been input, therefore no events information : trials will be aligned with the trigger');
end


%% load the data

% load input structures from inputStructs.files
if isfield(inputStructs, 'files')
    for ii = 1:length(inputStructs.files)
        inputStructs.files{ii} = load(inputStructs.files{ii});
    end
end
% load input event structures from inputEvents.files
if nargin > 1
    if isfield(inputEvents, 'files')
        for ii = 1:length(inputEvents.files)
            inputEvents.files{ii} = load(inputEvents.files{ii});
        end
    end
end

% concatenate input files and input structures
if ~isfield(inputStructs,'structures')
    inputStructs.structures = {};
end
if ischar(inputStructs.structures)
    inputStructs.structures = {inputStructs.structures};
end
if ~iscell(inputStructs.structures)
    error('''structures'' field of inputStructs must be a cell array of time-frequency elements');
end
if isfield(inputStructs, 'files')
    for ii = 1:length(inputStructs.files)
        field = fieldnames(inputStructs.files{ii});
        for jj = 1:length(field)
            inputStructs.structures{end+1} = inputStructs.files{ii}.(field{jj});
        end
    end
end

% concatenate input event files and input event structures
if ~isempty(inputEvents)
    if ~isfield(inputEvents,'structures')
        inputEvents.structures = {};
    end
    if ischar(inputEvents.structures)
        inputEvents.structures = {inputEvents.structures};
    end
    if ~iscell(inputEvents.structures)
        error('''structures'' field of inputEvents must be a cell array of PANAM TrialParams structures');
    end
    if isfield(inputEvents, 'files')
        for ii = 1:length(inputEvents.files)
            field = fieldnames(inputEvents.files{ii});
            for jj = 1:length(field)
                inputEvents.structures{end+1} = inputEvents.files{ii}.(field{jj});
            end
        end
    end
end


%% check the final structure

% check for identical structures, which throws an error
for ii = 1:length(inputStructs.structures)-1
    for jj =ii+1:length(inputStructs.structures)
        if isequal(inputStructs.structures{ii}.Infos, inputStructs.structures{jj}.Infos)
            error('replications of structures in the input - please check the unicity of the inputs');
        end
    end
end
if ~isempty(inputEvents)
    for ii = 1:length(inputEvents.structures)-1
        for jj =ii+1:length(inputEvents.structures)
            if isequal(inputEvents.structures{ii}.Infos, inputEvents.structures{jj}.Infos)
                error('replications of structures in the input - please check the unicity of the inputs');
            end
        end
    end
end


%% average contacts
% define the contacts selected for each input structure
% then average over the contacts


%% trials filtering
% select trials which correpond to the specified filter


%% subject averaging
% in case of multi-subjcet inputs, average over subjects if option is selected


%% baseline correction
% apply baseline correction on the trials/subjects :
% decibel - zscore - ratio of change from baseline - (average t-maps ?)


%% events handling
% compute events averages


%% output affectation


%% visualization


end

