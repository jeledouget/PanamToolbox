function outputStruct = panam_timeFrequencyProcess( inputData, inputEvents, param )

%PANAM_TIMEFREQUENCYPROCESS Function to compute corrections and averages on
%Panam TimeFrequency structures

% inputData :
% must be a structure with field files : string or a cell array of
% strings (files addresses, partial or full), and with field path : folder in which to
% find the files (will be concatenated with the file address)
% OR a structure with field structures : PANAM_TIMEFREQUENCY structure or
% PANAM_TIMEFREQUENCY structure cell array
% Possible to mix both inputs but not recommended
% (OPTIONAL) inputEvents
% same as inputData but with PANAM_TRIALPARAMS as structure instead
% of PANAM_TIMEFREQUENCY
% (OPTIONAL) param:
% structure of parameters for the TIMEFREQUENCY preocessing operation


%% default parameters
% define the default parameters


%% check/affect parameters


%% check the format of input files and input events structures, and prepare for loading the data
% input files
if isfield(inputData,'files')
    if isempty(inputData.files)
        inputData = rmfield(inputData,'files');
    else % non-empty
        % one input as a string
        if ischar(inputData.files)
            inputData.files = {inputData.files};
        end
        if ~iscell(inputData.files) || ~all(cellfun(@ischar,inputData.files))
            error('''files'' field must be a string or cell array of strings');
        end
        % path
        if isfield(inputData,'path')
            if ischar(inputData.path)
                inputData.files = cellfun(@fullfile, ...
                    repmat({inputData.path},[1 length(inputData.files)]),inputData.files,'UniformOutput',0);
            else
                error('''path'' field in inputData must be a string indicating the common origin folder of the inputStruct files');
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
            if ~iscell(inputEvents.files) || ~all(cellfun(@ischar,inputData.files))
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

% load input structures from inputData.files
if isfield(inputData, 'files')
    for ii = 1:length(inputData.files)
        inputData.files{ii} = load(inputData.files{ii});
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
if ~isfield(inputData,'structures')
    inputData.structures = {};
end
if ~iscell(inputData.structures)
    error('''structures'' field of inputData must be a cell array of time-frequency elements');
end
if isfield(inputData, 'files')
    for ii = 1:length(inputData.files)
        field = fieldnames(inputData.files{ii});
        for jj = 1:length(field)
            inputData.structures{end+1} = inputData.files{ii}.(field{jj});
        end
    end
end
TimeFreqData = inputData.structures;
clear inputData;

% concatenate input event files and input event structures
if ~isempty(inputEvents)
    if ~isfield(inputEvents,'structures')
        inputEvents.structures = {};
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
    Events = inputEvents.structures;
else
    Events = {};
end
clear inputEvents;


%% check the final structure

% check for identical structures, which throws an error
for ii = 1:length(TimeFreqData)-1
    for jj = ii+1:length(TimeFreqData)
        if isequal(TimeFreqData{ii}.Infos, TimeFreqData{jj}.Infos)
            error('replications of structures in the input - please check the unicity of the inputs');
        end
    end
end
if ~isempty(Events)
    for ii = 1:length(Events)-1
        for jj =ii+1:length(Events)
            if isequal(Events{ii}.Infos, Events{jj}.Infos)
                error('replications of structures in the input - please check the unicity of the inputs');
            end
        end
    end
end

% check for correspondance between input structures and input events structures
if ~isempty(Events)
    % check the correspondance of structures (inputs and events)
    indices = [];
    for ii = 1:length(TimeFreqData)
        stringData = ['GBMOV_POSTOP_' TimeFreqData{ii}.Infos.SubjectCode '_' TimeFreqData{ii}.Infos.MedCondition '_' ...
                      TimeFreqData{ii}.Infos.SpeedCondition];
        stringsEvents = cellfun(@(x) x.Infos.FileName,Events,'UniformOutput',0);
        ind = find(strcmpi(stringsEvents, stringData));
        if length(ind) == 1 % one unique corresponding structure
            indices(ii) = ind;
        else
            error(['TimeFreq data structure number ' num2str(ii) ' (at least) has no corresponding events structure']);
        end
    end
    Events = Events(indices); % reorganize events so that data and events structures indices correspond
end


%% average contacts
% define the contacts selected for each input structure
% then average over the contacts

% filter contacts
% 1 - STN init
if any(arrayfun(@(x) strcmpi(x.filter,'STN'), param.contacts))
    try
        locContacts_isSTN = load(param.locContacts_STN_file);
    catch 
        error('param.locContacts_STN_file unspecified or wrong. Needs to be the full adress of the loc file');
    end
    temp = fieldnames(locContacts_isSTN);
    locContacts_isSTN = locContacts_isSTN.(temp{1});
end
% 2 - filter contacts
for ii = 1:length(TimeFreqData)
    for jj = 1:length(param.contacts)
        switch param.contacts(jj).filter
            case 'STN'
                temp = find(strcmpi([locContacts_isSTN.SubjectNumber],TimeFreqData{ii}.Infos.SubjectNumber),1);
                if ~isempty(temp)
                    filter_contacts{jj,ii} = find(locContacts_isSTN(temp).dipole);
                else
                    filter_contacts{jj,ii} = 1:6;
                    warning(['No STN localisation for subject number ' num2str(TimeFreqData{ii}.Infos.SubjectNumber) ', all contacts are supposed in the STN']);
                end
            case 'none'
                filter_contacts{jj,ii} = 1:6;
            otherwise
                error('param.contact.filter must be STN or none');
        end
    end
end

% contacts selection filter
powspctrmTmp = cell(1,length(TimeFreqData));
labelTmp = {};
% check dimord
for jj = 1:length(TimeFreqData)
    if ~strcmpi(TimeFreqData{jj}.TimeFreqTrials.dimord, 'rpt_chan_freq_time')
        error('dimord in time-freq structure must be rpt_chan_freq_time');
    end
end
% manage contacts in structure
for ii = 1:length(param.contacts)
    switch param.contacts(ii).selection
        case 'avgAll'
            for jj = 1:length(TimeFreqData)
                contacts = intersect(filter_contacts{ii,jj}, 1:6);
                if ~isempty(contacts)
                    powspctrmTmp{jj}(:,end+1,:,:) = nanmean(TimeFreqData{jj}.TimeFreqTrials.powspctrm(:,contacts,:,:),2);
                else
                    powspctrmTmp{jj}(:,end+1,:,:) = nan * ones(size(TimeFreqData{jj}.TimeFreqTrials.powspctrm(:,1,:,:)));
                end
            end
            labelTmp{end+1} = ['AvgAllContacts_Filter:' param.contacts(ii).filter];
        case 'avgLeft'
            for jj = 1:length(TimeFreqData)
                contacts = intersect(filter_contacts{ii,jj}, 4:6);
                if ~isempty(contacts)
                    powspctrmTmp{jj}(:,end+1,:,:) = nanmean(TimeFreqData{jj}.TimeFreqTrials.powspctrm(:,contacts,:,:),2);
                else
                    powspctrmTmp{jj}(:,end+1,:,:) = nan * ones(size(TimeFreqData{jj}.TimeFreqTrials.powspctrm(:,1,:,:)));
                end
            end
            labelTmp{end+1} = ['AvgLeftContacts_Filter:' param.contacts(ii).filter];
        case 'avgRight'
            for jj = 1:length(TimeFreqData)
                contacts = intersect(filter_contacts{ii,jj}, 1:3);
                if ~isempty(contacts)
                    powspctrmTmp{jj}(:,end+1,:,:) = nanmean(TimeFreqData{jj}.TimeFreqTrials.powspctrm(:,contacts,:,:),2);
                else
                    powspctrmTmp{jj}(:,end+1,:,:) = nan * ones(size(TimeFreqData{jj}.TimeFreqTrials.powspctrm(:,1,:,:)));
                end
            end
            labelTmp{end+1} = ['AvgRightContacts_Filter:' param.contacts(ii).filter];
        case 'all'
            test_all = true;
            contacts_all{1} = intersect(filter_contacts{ii,1}, 1:6);
            for jj = 2:length(TimeFreqData)
                contacts_all{jj} = intersect(filter_contacts{ii,jj}, 1:6);
                test_all = test_all * isequal(contacts_all{jj},contacts_all{jj-1});
            end
            if test_all
                for jj = 2:length(TimeFreqData)
                    powspctrmTmp{jj}(:,end+1:end+length(contacts_all{jj}),:,:) = TimeFreqData{jj}.TimeFreqTrials.powspctrm(:,contacts_all{jj},:,:);
                end
                labelTmp(end+1:end+length(contacts_all{1})) = TimeFreqData{1}.TimeFreqTrials.label(contacts_all{1});
            else
                warning('contacts ''all'' not added : incompatible with the filters');
            end
        case 'left'
            test_left = true;
            contacts_left{1} = intersect(filter_contacts{ii,1}, 4:6);
            for jj = 2:length(TimeFreqData)
                contacts_left{jj} = intersect(filter_contacts{ii,jj}, 4:6);
                test_left = test_left * isequal(contacts_left{jj},contacts_left{jj-1});
            end
            if test_left
                for jj = 2:length(TimeFreqData)
                    powspctrmTmp{jj}(:,end+1:end+length(contacts_left{jj}),:,:) = TimeFreqData{jj}.TimeFreqTrials.powspctrm(:,contacts_left{jj},:,:);
                end
                labelTmp(end+1:end+length(contacts_left{1})) = TimeFreqData{1}.TimeFreqTrials.label(contacts_left{1});
            else
                warning('contacts ''left'' not added : incompatible with the filters');
            end
        case 'right'
            test_right = true;
            contacts_right{1} = intersect(filter_contacts{ii,1}, 1:3);
            for jj = 2:length(TimeFreqData)
                contacts_right{jj} = intersect(filter_contacts{ii,jj}, 1:3);
                test_right = test_right * isequal(contacts_right{jj},contacts_right{jj-1});
            end
            if test_right
                for jj = 2:length(TimeFreqData)
                    powspctrmTmp{jj}(:,end+1:end+length(contacts_right{jj}),:,:) = TimeFreqData{jj}.TimeFreqTrials.powspctrm(:,contacts_right{jj},:,:);
                end
                labelTmp(end+1:end+length(contacts_right{1})) = TimeFreqData{1}.TimeFreqTrials.label(contacts_right{1});
            else
                warning('contacts ''right'' not added : incompatible with the filters');
            end
        case {1,2,3,4,5,6}
            test_unique = true;
            contacts_unique{1} = intersect(filter_contacts{ii,1}, param.contacts(ii).selection);
            for jj = 2:length(TimeFreqData)
                contacts_unique{jj} = intersect(filter_contacts{ii,jj}, param.contacts(ii).selection);
                test_unique = test_unique * isequal(contacts_unique{jj},contacts_unique{jj-1});
            end
            if test_unique
                for jj = 2:length(TimeFreqData)
                    powspctrmTmp{jj}(:,end+1,:,:) = TimeFreqData{jj}.TimeFreqTrials.powspctrm(:,param.contacts(ii).selection,:,:);
                end
                labelTmp(end+1) = label(param.contacts(ii).selection);
            else
                warning(['contact ' num2str(param.contacts(ii).selection) ' not added : incompatible with the filters']);
            end
        otherwise
            error('param.contacts is wrong');
    end
end

% affectation
for jj = 1:length(TimeFreqData)
    TimeFreqData{jj}.TimeFreqTrials.powspctrm = powspctrmTmp{jj};
    TimeFreqData{jj}.TimeFreqTrials.label = labelTmp;
end
clear powspctrmTmp;

%% trials filtering

% keep only common trials between Data and Events structures
for ii = 1:length(TimeFreqData)
    trialNumData = TimeFreqData{ii}.TimeFreqTrials.TrialNum;
    trialNumEvents = [Events{ii}.Trial.TrialNum];
    [sortedCommonTrialNums indCommonTrData indCommonTrEvents] = intersect(trialNumData, trialNumEvents);
    TimeFreqData{ii}.TimeFreqTrials.powspctrm = TimeFreqData{ii}.TimeFreqTrials.powspctrm(indCommonTrData,:,:,:);
    TimeFreqData{ii}.TimeFreqTrials.cumtapcnt = TimeFreqData{ii}.TimeFreqTrials.cumtapcnt(indCommonTrData,:);
    TimeFreqData{ii}.TimeFreqTrials.TrialName = TimeFreqData{ii}.TimeFreqTrials.TrialName(indCommonTrData);
    TimeFreqData{ii}.TimeFreqTrials.TrialNum = TimeFreqData{ii}.TimeFreqTrials.TrialNum(indCommonTrData);
    Events{ii}.Trial = Events{ii}.Trial(indCommonTrEvents);
end

% select trials which correpond to the specified filter
if strcmpi(param.trialFilter, 'leftStarts') || strcmpi(param.trialFilter, 'rightStarts')
    if ~isempty(Events)
        if strcmpi(param.trialFilter, 'leftStarts')
            for jj = 1:length(Events)
                trialInd = find(strcmpi({Events{jj}.Trial.StartingFoot}, 'Left'));
                if ~isempty(trialInd)
                    TimeFreqData{jj}.TimeFreqTrials.powspctrm = TimeFreqData{jj}.TimeFreqTrials.powspctrm(trialInd,:,:,:);
                    TimeFreqData{jj}.TimeFreqTrials.cumtapcnt = TimeFreqData{jj}.TimeFreqTrials.cumtapcnt(trialInd,:);
                    TimeFreqData{jj}.TimeFreqTrials.TrialName = TimeFreqData{jj}.TimeFreqTrials.TrialName(trialInd);
                    TimeFreqData{jj}.TimeFreqTrials.TrialNum = TimeFreqData{jj}.TimeFreqTrials.TrialNum(trialInd);
                    Events{jj}.Trial = Events{jj}.Trial(trialInd);
                else
                    TimeFreqData{jj}.TimeFreqTrials = [];
                    Events{jj} = [];
                    warning(['no trials after left starts filtering for structure ' TimeFreqData{jj}.Infos.FileName]);
                end
            end
        elseif strcmpi(param.trialFilter, 'rightStarts')
            for jj = 1:length(Events)
                trialInd = find(strcmpi({Events{jj}.Trial.StartingFoot}, 'Right'));
                if ~isempty(trialInd)
                    TimeFreqData{jj}.TimeFreqTrials.powspctrm = TimeFreqData{jj}.TimeFreqTrials.powspctrm(trialInd,:,:,:);
                    TimeFreqData{jj}.TimeFreqTrials.cumtapcnt = TimeFreqData{jj}.TimeFreqTrials.cumtapcnt(trialInd,:);
                    TimeFreqData{jj}.TimeFreqTrials.TrialName = TimeFreqData{jj}.TimeFreqTrials.TrialName(trialInd);
                    TimeFreqData{jj}.TimeFreqTrials.TrialNum = TimeFreqData{jj}.TimeFreqTrials.TrialNum(trialInd);
                    Events{jj}.Trial = Events{jj}.Trial(trialInd);
                else
                    TimeFreqData{jj}.TimeFreqTrials = [];
                    Events{jj} = [];
                    warning(['no trials after right starts filtering for structure ' TimeFreqData{jj}.Infos.FileName]);
                end
            end
        end
    else
        error('trial filter cannot be applied : TrialParams structures are required');
    end
end

% suppress the empty structures
ind = [];
for ii = 1:length(TimeFreqData)
    if ~isempty(TimeFreqData{ii}.TimeFreqTrials)
        ind(end+1) = ii;
    end
end
TimeFreqData = TimeFreqData(ind);
Events = Events(ind);


%% save the baseline
for ii = 1:length(TimeFreqData)
    firstBlSample = find(abs(TimeFreqData{ii}.TimeFreqTrials.time - param.blStartTime) == min(abs(TimeFreqData{ii}.TimeFreqTrials.time - param.blStartTime)));
    lastBlSample = find(abs(TimeFreqData{ii}.TimeFreqTrials.time - param.blEndTime) == min(abs(TimeFreqData{ii}.TimeFreqTrials.time - param.blEndTime)));
    TimeFreqData{ii}.TimeFreqTrials.blPowspctrm = TimeFreqData{ii}.TimeFreqTrials.powspctrm(:,:,:,firstBlSample:lastBlSample);
end

%% align events on selected marker
% set selected marker (param.marker) time at 0
for ii = 1:length(Events)
    indGoodTrials = [];
    for jj = 1:length(Events{ii}.Trial)
        markerNum = find(strcmpi(Events{ii}.Trial(jj).EventsNames, param.marker));
        if length(markerNum) ~=1
            error('problem in param.marker');
        end
        if~isnan(Events{ii}.Trial(jj).EventsTime(markerNum)) && ~isnan(Events{ii}.Trial(jj).EventsTime(1))
            Events{ii}.Trial(jj).EventsTime = Events{ii}.Trial(jj).EventsTime - Events{ii}.Trial(jj).EventsTime(markerNum);
            indGoodTrials(end+1) = jj;
        else
            warning(['presence of NaNs in trial ' Events{ii}.Trial(jj).TrialName ' : trial suppressed from analysis']);
        end
    end
    if ~isempty(indGoodTrials)
        Events{ii}.Trial = Events{ii}.Trial(indGoodTrials);
        TimeFreqData{ii}.TimeFreqTrials.powspctrm = TimeFreqData{ii}.TimeFreqTrials.powspctrm(indGoodTrials,:,:,:);
        TimeFreqData{ii}.TimeFreqTrials.cumtapcnt = TimeFreqData{ii}.TimeFreqTrials.cumtapcnt(indGoodTrials,:);
        TimeFreqData{ii}.TimeFreqTrials.TrialName = TimeFreqData{ii}.TimeFreqTrials.TrialName(indGoodTrials);
        TimeFreqData{ii}.TimeFreqTrials.TrialNum = TimeFreqData{ii}.TimeFreqTrials.TrialNum(indGoodTrials);
        TimeFreqData{ii}.TimeFreqTrials.blPowspctrm = TimeFreqData{ii}.TimeFreqTrials.blPowspctrm(indGoodTrials,:,:,:);
    else
        TimeFreqData{ii}.TimeFreqTrials = [];
        Events{ii} = [];
        warning('no trials left after marker times analysis');
    end
end

% suppress the empty structures
ind = [];
for ii = 1:length(TimeFreqData)
    if ~isempty(TimeFreqData{ii}.TimeFreqTrials)
        ind(end+1) = ii;
    end
end
TimeFreqData = TimeFreqData(ind);
Events = Events(ind);


%% select the period of interest
for ii = 1:length(TimeFreqData)
    powspctrmTmp = [];
    timeStepTimeFreq = (TimeFreqData{ii}.TimeFreqTrials.time(end) - TimeFreqData{ii}.TimeFreqTrials.time(1)) / (length(TimeFreqData{ii}.TimeFreqTrials.time)-1);
    nSamplesPre = round(param.preMarkerTime/timeStepTimeFreq);
    nSamplesPost = round(param.postMarkerTime/timeStepTimeFreq);
    for jj = 1:length(TimeFreqData{ii}.TimeFreqTrials.TrialNum)
        markerTime = -1 * Events{ii}.Trial(jj).EventsTime(1);
        markerSample = find(abs(TimeFreqData{ii}.TimeFreqTrials.time - markerTime) == min(abs(TimeFreqData{ii}.TimeFreqTrials.time - markerTime)));
        firstSample = markerSample - nSamplesPre;
        lastSample = markerSample + nSamplesPost;
        powspctrmTmp(jj,:,:,:) = TimeFreqData{ii}.TimeFreqTrials.powspctrm(jj,:,:,firstSample:lastSample);
    end
    TimeFreqData{ii}.TimeFreqTrials.powspctrm = powspctrmTmp;
    TimeFreqData{ii}.TimeFreqTrials.time = linspace(-param.preMarkerTime, param.postMarkerTime, nSamplesPre+nSamplesPost+1);
end


%% intra-subject averaging
% concatenate structures per subject
if strcmpi(param.avgIntraSubjects, 'yes')
    indToBeKept = [];
    for jj = 1:length(TimeFreqData)
        subjIndices = find(cellfun(@(x) x.Infos.SubjectNumber, TimeFreqData) == TimeFreqData{jj}.Infos.SubjectNumber);
        if subjIndices(1) >= jj % subject not treated before
            for kk = 2:length(subjIndices)
                TimeFreqData{subjIndices(1)}.TimeFreqTrials.powspctrm = cat(1,...
                    TimeFreqData{subjIndices(1)}.TimeFreqTrials.powspctrm, TimeFreqData{subjIndices(kk)}.TimeFreqTrials.powspctrm);
                TimeFreqData{subjIndices(1)}.TimeFreqTrials.cumtapcnt = cat(1,...
                    TimeFreqData{subjIndices(1)}.TimeFreqTrials.cumtapcnt, TimeFreqData{subjIndices(kk)}.TimeFreqTrials.cumtapcnt);
                TimeFreqData{subjIndices(1)}.TimeFreqTrials.TrialName = cat(2,...
                    TimeFreqData{subjIndices(1)}.TimeFreqTrials.TrialName, TimeFreqData{subjIndices(kk)}.TimeFreqTrials.TrialName);
                TimeFreqData{subjIndices(1)}.TimeFreqTrials.TrialNum = cat(2,...
                    TimeFreqData{subjIndices(1)}.TimeFreqTrials.TrialNum, TimeFreqData{subjIndices(kk)}.TimeFreqTrials.TrialNum);
                TimeFreqData{subjIndices(1)}.TimeFreqTrials.blPowspctrm = cat(1,...
                    TimeFreqData{subjIndices(1)}.TimeFreqTrials.blPowspctrm, TimeFreqData{subjIndices(kk)}.TimeFreqTrials.blPowspctrm);
                Events{subjIndices(1)}.Trial = cat(2, Events{subjIndices(1)}.Trial,Events{subjIndices(kk)}.Trial);
            end
            indToBeKept(end+1) = subjIndices(1);
        end
    end
    TimeFreqData = TimeFreqData(indToBeKept);
    Events = Events(indToBeKept);
    % average over the subject
    for jj = 1:length(TimeFreqData)
        TimeFreqData{jj}.TimeFreqTrials.powspctrm = nanmean(TimeFreqData{jj}.TimeFreqTrials.powspctrm,1);
        if isequal(TimeFreqData{jj}.TimeFreqTrials.cumtapcnt,...
                repmat(TimeFreqData{jj}.TimeFreqTrials.cumtapcnt(1,:),size(TimeFreqData{jj}.TimeFreqTrials.cumtapcnt,1),1))
            TimeFreqData{jj}.TimeFreqTrials.cumtapcnt = TimeFreqData{jj}.TimeFreqTrials.cumtapcnt(1,:);
        else
            TimeFreqData{jj}.TimeFreqTrials = rmfield(TimeFreqData{jj}.TimeFreqTrials.cumtapcnt,'cumtapcnt');
        end
        TimeFreqData{subjIndices(1)}.TimeFreqTrials.TrialName = ['Average_' TimeFreqData{subjIndices(1)}.Infos.SubjectCode];
        TimeFreqData{subjIndices(1)}.TimeFreqTrials.TrialNum = 1;
        Events{jj}.Trial(1).EventsTime = nanmean(vertcat(Events{jj}.Trial.EventsTime),1);
        Events{jj}.Trial(1).TrialName = ['Average_' TimeFreqData{subjIndices(1)}.Infos.SubjectCode];
        Events{jj}.Trial(1).TrialNum = 1;
        Events{jj}.Trial = Events{jj}.Trial(1);
        Events{jj}.Trial = rmfield(Events{jj}.Trial,'StartingFoot');
    end
end


%% baseline correction
% apply baseline correction on the trials/subjects :
% decibel - zscore - ratio of change from baseline - (average t-maps ?)
for jj = 1:length(TimeFreqData)
    TimeFreqData{jj}.Trial = panam_blCorrection(TimeFreqData{jj}.Trial,param.blCorrection);
end

%% output affectation
% concatenate final structures
outputStruct.TimeFreqTrials = outputStruct.TimeFreqTrials{1};
for ii = 2:length(TimeFreqData)
    outputStruct.TimeFreqTrials.powscptrm = cat(1, outputStruct.TimeFreqTrials.powscptrm, TimeFreqData{ii}.powspctrm);
end

%% visualization


end

