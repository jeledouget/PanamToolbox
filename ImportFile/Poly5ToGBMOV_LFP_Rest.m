function [lfp_out] = Poly5ToGBMOV_LFP_Rest(filename)

%GBMOVSTRUCT_POLY5 Load Poly5 recordings and create Signal_LFP structure,
%for recordings at rest
%   09/09/2014 Jean-Eudes Le Douget, CENIR

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
elseif any(cellfun(@(x) ~isempty(x),strfind(lower(parseRecord),'prisedopa')))
    medCondition = upper(parseRecord{cellfun(@(x) ~isempty(x),strfind(lower(parseRecord),'prisedopa'))});
else
    medCondition = 'UNKNOWN';
end

if any(strcmpi('assis',parseRecord))
    sitStandCondition = 'Assis';
elseif any(strcmpi('Debout',parseRecord))
    sitStandCondition = 'Debout';
else
    sitStandCondition = 'UNKNOWN';
end

% check inbox
infos = inputdlg({'SubjectCode','MedCondition','SitStandCondition'},'Check inputs',1,{subjectCode, medCondition, sitStandCondition});
subjectCode = infos{1};
subjectNumber = str2double(subjectCode(end-1:end));
medCondition = infos{2};
sitStandCondition = infos{3};


tag = {'C_01D', 'C_12D', 'C_23D', 'C_01G', 'C_12G', 'C_23G'};
units = {'uV', 'uV', 'uV', 'uV', 'uV', 'uV'};
fech = hdr.fs;
protocole = 'GBMOV';
session = 'POSTOP';
type = 'RestLFP';
fileNameOut = upper([protocole '_' session '_' subjectCode  '_' medCondition '_' sitStandCondition '_' type]);

%% signal

data = data_temp(2:7,:);
time = 1/fech *(0:length(data)-1);
trialNum = 1;
trialName = [fileNameOut '_' num2str(trialNum,'%02d')];
description{1} = 'Signal LFP. Rest Recording';
trial(1).Raw = Signal_LFP(data, fech, 'Tag', tag, 'Units', units, 'Time', time, 'TrialName', trialName, 'TrialNum', trialNum, 'Description', description);
trial(1).PreProcessed = trial(1).Raw.PreProcessingLFP;

history = cell(1,2);
history{1,1} = datestr(clock);
history{1,2} = ['Creation of the structure from file ' filename];


%% create output structure
lfp_out.Infos.SubjectCode = subjectCode;
lfp_out.Infos.SubjectNumber = subjectNumber;
lfp_out.Infos.MedCondition = medCondition;
lfp_out.Infos.SitStandCondition = sitStandCondition ;
lfp_out.Infos.FileName = fileNameOut;
lfp_out.Trial = trial;
lfp_out.History = history;

end

