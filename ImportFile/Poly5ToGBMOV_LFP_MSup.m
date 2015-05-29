function [lfp_out] = Poly5ToGBMOV_LFP_MSup(filename)

%GBMOVSTRUCT_POLY5 Load Poly5 recordings and create Signal_LFP structure
%for MSup experiment
%   09/09/2014 Jean-Eudes Le Douget, CENIR

%% load the components of the poly5 file : header and sampled recordings
[hdr data_temp] = tms_read_to_edf_struct(filename);
% test the number of channels
if size(data_temp,1)~=7
    error(['Number of channels in ' filename ' is not equal to 7']);
end

%% affect params for output structure
subjectCode = hdr.patientID;
subjectNumber = str2double(subjectCode(end-1:end));
parseRecord = strsplit(hdr.recordID,'_');
if any(strcmpi('ON',parseRecord))
    medCondition = 'ON';
elseif any(strcmpi('OFF',parseRecord))
    medCondition = 'OFF';
else
    button = questdlg('No medical condition found in header. Do you know it ?','Medical Condition', 'OFF','ON', 'Unknown', 'OFF');
    medCondition = button;
end
tag = {'C_01D', 'C_12D', 'C_23D', 'C_01G', 'C_12G', 'C_23G'};
units = {'uV', 'uV', 'uV', 'uV', 'uV', 'uV'};
fech = hdr.fs;
protocole = 'GBMOV';
session = 'MSupPostop';
type = 'LFP';
fileNameOut = [protocole '_' session '_' subjectCode  '_' medCondition '_' type];

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
    data = data_temp(2:7,max(1,trig(ii)-fech):min(trig(ii)+3*fech,length(data_temp)));
    time = 1/fech *(- min(trig(ii),fech) + (0:length(data)-1));
    trialNum = ii;
    trialName = [fileNameOut '_' num2str(ii,'%02d')];
    description{1} = 'Signal LFP. MSup';
    trial(ii).Raw = Signal_LFP(data, fech, 'Tag', tag, 'Units', units, 'Time', time, 'TrialName', trialName, 'TrialNum', trialNum, 'Description', description);
    trial(ii).PreProcessed = trial(ii).Raw.PreProcessingLFP;
end

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
lfp_out.Trial = trial;
lfp_out.History = history;
lfp_out.RemovedTrials = removedTrials;

end

