function [lfp_out] = Poly5ToGBMOV_LFP_RealGait(filename)

%GBMOVSTRUCT_POLY5 Load Poly5 recordings and create Signal_LFP structure
%   03/09/2014 Jean-Eudes Le Douget, CENIR

%% parameters for the trial

% time pre and post trigger for trial identification
timePreTrigger = 3;
timePostTrigger = 5;

%% load the components of the poly5 file : header and sampled recordings
[hdr data_temp] = tms_read_to_edf_struct(filename);
% test the number of channels
if size(data_temp,1)~=7
    error(['Number of channels in ' filename ' is not equal to 7']);
end

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
infos = inputdlg({'SubjectCode','MedCondition','SitStandCondition'},'Check inputs',1,{subjectCode, medCondition, speedCondition});
subjectCode = infos{1};
subjectNumber = str2double(subjectCode(end-1:end));
medCondition = infos{2};
speedCondition = infos{3};

tag = {'C_01D', 'C_12D', 'C_23D', 'C_01G', 'C_12G', 'C_23G'};
units = {'uV', 'uV', 'uV', 'uV', 'uV', 'uV'};
fech = hdr.fs;
protocole = 'GBMOV';
session = 'POSTOP';
type = 'LFP';
fileNameOut = upper([protocole '_' session '_' subjectCode  '_' medCondition '_' speedCondition '_' type]);

%% signal
temp_trigg = find(data_temp(1,:)~=2);
trig=temp_trigg(1);
for ii = 2:length(temp_trigg)
    if temp_trigg(ii)~=temp_trigg(ii-1)+1
        trig(end+1) = temp_trigg(ii);
    end
end

trial(length(trig)).Raw = [];
for ii=1:length(trig)
    data = data_temp(2:7,max(1,trig(ii)-timePreTrigger*fech):min(trig(ii)+timePostTrigger*fech,length(data_temp)));
    time = 1/fech *(- min(trig(ii),timePreTrigger*fech) + (0:length(data)-1));
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

