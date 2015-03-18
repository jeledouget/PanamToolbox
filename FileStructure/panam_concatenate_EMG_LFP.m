function outputStruct = panam_concatenate_EMG_LFP(inputLFP, inputEMG )


%PANAM_CONCATENATE_EMG_LFP Summary of this function goes here
%   Detailed explanation goes here

%% load if necessary
if ~nargin || isempty(inputLFP) || isempty(inputEMG)
    [fileLFP, pathLFP] = uigetfile('*.mat', 'Select input LFP file');
    [fileEMG, pathEMG] = uigetfile('*.mat', 'Select input EMG file');
    inputLFP = load(fullfile(pathLFP, fileLFP));
    inputEMG= load(fullfile(pathEMG, fileEMG));
    field = fieldnames(inputLFP);
    inputLFP = inputLFP.(field{1});
    field = fieldnames(inputEMG);
    inputEMG = inputEMG.(field{1});
end

%% extract
dataEMG  = inputEMG.Trial;
dataLFP = inputLFP.Trials;


%%

for ii=1:length(dataEMG)
    dataEMG(ii).ResampledRAW = dataEMG(ii).RAW.Resampling(dataLFP(1).PreProcessed.Fech);
end

dataEMG = rmfield(dataEMG,{'RAW','TKEO','Bouffee','Activite'});
dataLFP = rmfield(dataLFP,'Raw');


%% common trials
trialsEMG = arrayfun(@(x) x.ResampledRAW.TrialName, dataEMG, 'UniformOutput', 0);
trialsLFP = arrayfun(@(x) x.PreProcessed.TrialName, dataLFP, 'UniformOutput', 0);
[~,emgTrials, lfpTrials] = intersect(upper(trialsEMG),upper(trialsLFP));
dataEMG = dataEMG(emgTrials);
dataLFP = dataLFP(lfpTrials);


%% concatenation
orderEMGTrials = arrayfun(@(y) find(arrayfun(@(x) strcmpi(x.ResampledRAW.TrialName, y.PreProcessed.TrialName),dataEMG)),dataLFP);
for ii = 1:length(dataLFP)
    % time
    minTime = max(dataLFP(ii).PreProcessed.Time(1),dataEMG(orderEMGTrials(ii)).ResampledRAW.Time(1));
    maxTime = min(dataLFP(ii).PreProcessed.Time(end),dataEMG(orderEMGTrials(ii)).ResampledRAW.Time(end));
    [~,minIndLFP] = min(abs(dataLFP(ii).PreProcessed.Time - minTime));
    [~,minIndEMG] = min(abs(dataEMG(orderEMGTrials(ii)).ResampledRAW.Time - minTime));
    [~,maxIndLFP] = min(abs(dataLFP(ii).PreProcessed.Time - maxTime));
    [~,maxIndEMG] = min(abs(dataEMG(orderEMGTrials(ii)).ResampledRAW.Time - maxTime));
    % check
    if (maxIndEMG - minIndEMG) ~= (maxIndLFP - minIndLFP)
        error('EMG and LFP appear not to be the same size');
    end
    time = dataLFP(ii).PreProcessed.Time(minIndLFP:maxIndLFP);
    % data
    data = dataLFP(ii).PreProcessed.Data(:,minIndLFP:maxIndLFP);
    data = cat(1,data, dataEMG(orderEMGTrials(ii)).ResampledRAW.Data(:,minIndEMG:maxIndEMG));
    %fech
    if dataLFP(ii).PreProcessed.Fech == dataEMG(orderEMGTrials(ii)).ResampledRAW.Fech
        fech = dataLFP(ii).PreProcessed.Fech;
    else
        error('Fech must be identitical for merged structures : resampling step necessary');
    end
    % units
    units = cat(2,dataLFP(ii).PreProcessed.Units, dataEMG(orderEMGTrials(ii)).ResampledRAW.Units);
    % trialName
    trialname = dataLFP(ii).PreProcessed.TrialName;
    %trialNum
    trialnum = dataLFP(ii).PreProcessed.TrialNum;
    % description
    description = 'Structure with both LFP and EMG signals integrated';
    % tag
    tag = cat(2,dataLFP(ii).PreProcessed.Tag, dataEMG(orderEMGTrials(ii)).ResampledRAW.Tag');
    % constructor
    dataAll(ii).PreProcessed = Signal(data, fech,...
                                     {'time',time,...
                                     'units',units,...
                                     'trialname',trialname,...
                                     'trialnum',trialnum,...
                                     'description', description,...
                                     'tag',tag});
end

%% affectation

outputStruct.Infos = inputLFP.Infos;
outputStruct.Infos.Type = 'LFP_and_EMG';
outputStruct.Infos.FileName = [outputStruct.Infos.FileName 'andEMG'];
outputStruct.Trials = dataAll;
outputStruct.removedTrials = [];
outputStruct.History = inputLFP.History;
outputStruct.History{end+1,1} = datestr(clock);
outputStruct.History{end,2} = 'EMG Trials added to the LFP structure';