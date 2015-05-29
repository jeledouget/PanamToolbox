function [lfp_out] = EdfToGBMOV_LFP_RealGait(filename)

%GBMOVSTRUCT_POLY5 Load EDF recordings and create Signal_LFP structure
%  16/01/2015 Jean-Eudes Le Douget, CENIR

%% parameters for the trial

% time pre and post trigger for trial identification
timePreTrigger = 3;
timePostTrigger = 5;

%% load the components of the pEDF file : header and sampled recordings
[hdr data_temp] = edfRead(filename);

%% affect params for output structure
parseRecord = regexp(hdr.recordID,'_','split');
indexSubject = find(cellfun(@(x) length(x)==7 && ~isempty(str2num(x(end-1:end))),parseRecord));
try
    subjectCode = parseRecord{indexSubject(1)};
catch
    subjectCode = 'UNKNOWN';
end

if any(strcmpi('ON',parseRecord))
    medCondition = 'ON';
elseif any(strcmpi('OFF',parseRecord))
    medCondition = 'OFF';
else
    medCondition = 'UNKNOWN';
end

if any(strcmpi('S',parseRecord))
    speedCondition = 'S';
elseif any(strcmpi('R',parseRecord))
    speedCondition = 'R';
else
    speedCondition = 'UNKNOWN';
end

% check inbox
infos = inputdlg({'SubjectCode','MedCondition','SpeedCondition'},'Check inputs',1,{subjectCode, medCondition, speedCondition});
subjectCode = infos{1};
subjectNumber = str2double(subjectCode(end-1:end));
medCondition = infos{2};
speedCondition = infos{3};

tag = {'C_01D', 'C_12D', 'C_23D', 'C_01G', 'C_12G', 'C_23G'};
for ii = 1:length(tag)
    tag_channel(ii) = find(cellfun(@(x) all(ismember(tag{ii}(end-2:end), x)), hdr.label));
end
units = {'uV', 'uV', 'uV', 'uV', 'uV', 'uV'};
fech = 512; %hdr.fs;
protocole = 'PPN';
session = 'POSTOP';
type = 'LFP';
fileNameOut = upper([protocole '_' session '_' subjectCode  '_' medCondition '_' speedCondition '_' type]);

%% signal
trigg_Channel = find(cellfun(@(x) ismember('t', lower(x)), hdr.label));
trigg  = data_temp(trigg_Channel,:);
trigg_binary = clean_trigger_v2(trigg,fech);
trigg_samples = find(trigg_binary);
figure;
plot(trigg);
hold on;
for ii = 1:length(trigg_samples)
    plot([trigg_samples(ii) trigg_samples(ii)], [0 2*max(trigg)],'r');
end
isOkTriggers = questdlg('OK?','', 'Yes','No','Yes');
if(strcmpi(isOkTriggers,'No'))
    disp('please re-define trigg_samples, and exit keyboard mode with typing ''return''');
    keyboard;
end

trial(length(trigg_samples)).Raw = [];
for ii=1:length(trigg_samples)
    data = data_temp(tag_channel,max(1,trigg_samples(ii)-timePreTrigger*fech):min(trigg_samples(ii)+timePostTrigger*fech,length(data_temp)));
    time = 1/fech *(- min(trigg_samples(ii),timePreTrigger*fech) + (0:length(data)-1));
    trialNum = ii;
    trialName = [protocole '_' session '_' subjectCode  '_' medCondition '_' speedCondition '_' num2str(ii,'%02d')];
    description{1} = 'Signal LFP. Real Gait';
    trial(ii).Raw = Signal_LFP(data, fech, 'Tag', tag, 'Units', units, 'Time', time, 'TrialName', trialName, 'TrialNum', trialNum, 'Description', description);
    trial(ii).PreProcessed = trial(ii).Raw.PreProcessingLFP;
end

removedTrials = [];

history = cell(1,2);
history{1,1} = datestr(clock);
history{1,2} = ['Creation of the structure from file ' filename];

%% create output structure
lfp_out.Infos.SubjectCode = subjectCode;
lfp_out.Infos.SubjectNumber = subjectNumber;
lfp_out.Infos.MedCondition = medCondition ;
lfp_out.Infos.SpeedCondition = speedCondition;
lfp_out.Infos.Protocole = protocole;
lfp_out.Infos.Session = session;
lfp_out.Infos.Type = type;
lfp_out.Infos.FileName = fileNameOut;
lfp_out.Trials = trial;
lfp_out.History = history;
lfp_out.RemovedTrials = removedTrials;

end

