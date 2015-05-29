function [lfp_out] = Poly5ToGBMOV_LFP_GONOGO(filename)

%GBMOVSTRUCT_POLY5 Load Poly5 recordings and create Signal_LFP structure
%for GONOGO experiment
%   21/01/2015 Jean-Eudes Le Douget, CENIR

%% load the components of the poly5 file : header and sampled recordings
[hdr data_temp] = tms_read_to_edf_struct(filename);

%% affect params for output structure
subjectCode = hdr.patientID;
% check
subjectCode = inputdlg('Confirm/change the subject code','Check subject code',1,{subjectCode});
subjectCode = subjectCode{1};
subjectNumber = str2double(subjectCode(end-1:end));
parseRecord = regexp(hdr.recordID,'_','split');
if any(strcmpi('ON',parseRecord))
    medCondition = 'ON';
elseif any(strcmpi('OFF',parseRecord))
    medCondition = 'OFF';
else
    button = questdlg('No medical condition found in header. Do you know it ?','Medical Condition', 'OFF','ON', 'Unknown', 'OFF');
    medCondition = button;
end
tag = {'C_01D', 'C_12D', 'C_23D', 'C_01G', 'C_12G', 'C_23G'};
for ii = 1:length(tag)
    tag_channel(ii) = find(cellfun(@(x) all(ismember(tag{ii}(end-2:end), x)), hdr.label));
end
units = {'uV', 'uV', 'uV', 'uV', 'uV', 'uV'};
fech = hdr.fs;
protocole = 'GBMOV';
session = 'GonogoPostop';
type = 'LFP';
fileNameOut = [protocole '_' session '_' subjectCode  '_' medCondition '_' type];

%% signal
data_trigg = data_temp(cellfun(@(x) ismember('t', lower(x)), hdr.label),:);
temp_trigg = find(data_trigg(1,:)~=2);
trig=temp_trigg(1);
for ii = 2:length(temp_trigg)
    if temp_trigg(ii)~=temp_trigg(ii-1)+1
        trig(end+1) = temp_trigg(ii);
    end
end

trial(length(trig)).Raw = [];

for ii=1:length(trig)-1
    data = data_temp(tag_channel,trig(ii):trig(ii+1)-1);
    time = 1/fech *(0:size(data,2)-1);
    trialNum = ii;
    trialName = [fileNameOut '_' num2str(ii,'%02d')];
    description{1} = 'Signal LFP. Gonogo task';
    trial(ii).Raw = Signal_LFP(data, fech, 'Tag', tag, 'Units', units, 'Time', time, 'TrialName', trialName, 'TrialNum', trialNum, 'Description', description);
    trial(ii).PreProcessed = trial(ii).Raw.PreProcessingLFP;
end
% last trigger:
data = data_temp(tag_channel,trig(length(trig)):end);
time = 1/fech *(0:size(data,2)-1);
trialNum = length(trig);
trialName = [fileNameOut '_' num2str(length(trig),'%02d')];
description{1} = 'Signal LFP. Gonogo task';
trial(length(trig)).Raw = Signal_LFP(data, fech, 'Tag', tag, 'Units', units, 'Time', time, 'TrialName', trialName, 'TrialNum', trialNum, 'Description', description);
trial(length(trig)).PreProcessed = trial(length(trig)).Raw.PreProcessingLFP;

removedTrials = [];

history = cell(1,2);
history{1,1} = date;
history{1,2} = ['Creation of the structure from file ' filename];

%% create output structure
lfp_out.Infos.SubjectCode = subjectCode;
lfp_out.Infos.SubjectNumber = subjectNumber;
lfp_out.Infos.MedCondition = medCondition ;
lfp_out.Infos.Protocole = protocole;
lfp_out.Infos.Session = session;
lfp_out.Infos.Type = type;
lfp_out.Infos.FileName = fileNameOut;
lfp_out.Trials = trial;
lfp_out.History = history;
lfp_out.RemovedTrials = removedTrials;

end

