function [lfp_out] = EdfToGBMOV_LFP_Rest_Add(lfp_var, filename)

%GBMOVSTRUCT_ADDPOLY5 Add the content of a Poly5 file to an existing LFP
% GBMOV structure, in case of several recording files for a single subject
% and condition
%   03/09/2014 Jean-Eudes Le Douget, CENIR

%% load the components of the poly5 file : header and sampled recordings
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
for ii = 1:length(tag)
    tag_channel(ii) = find(cellfun(@(x) all(ismember(tag{ii}(end-2:end), x)), hdr.label));
end

units = {'uV', 'uV', 'uV', 'uV', 'uV', 'uV'};
fech = 512; %hdr.fs;
protocole = 'PPN';
session = 'POSTOP';
type = 'RestLFP';
fileNameOut = upper([protocole '_' session '_' subjectCode  '_' medCondition '_' sitStandCondition '_' type]);

%% check for consistency of the added file
if ~strcmp(subjectCode, lfp_var.Infos.SubjectCode)
    error('Subject names differ');
end
if subjectNumber ~= lfp_var.Infos.SubjectNumber
    error('Subject numbers differ');
end
if ~strcmp(medCondition, lfp_var.Infos.MedCondition)
    error('Medical conditions differ');
end
if ~strcmp(sitStandCondition, lfp_var.Infos.SitStandCondition)
    error('Sit/stand conditions differ');
end
if fech ~= lfp_var.Trial(1).Raw.Fech
    error('Sampling frequencies differ');
end

%% signal

nTrialsBefore = length(lfp_var.Trial);
trial(1).Raw = [];

data = data_temp(tag_channel,:);
time = 1/fech*(0:length(data)-1);
trialNum = nTrialsBefore + 1;
trialName = [fileNameOut '_' num2str(trialNum,'%02d')];
description{1} = 'Signal LFP. Rest recording.';
trial(1).Raw = Signal_LFP(data, fech, 'Tag', tag, 'Units', units, 'Time', time, 'TrialName', trialName, 'TrialNum', trialNum, 'Description', description);
trial(1).PreProcessed = trial(1).Raw.PreProcessingLFP;


history = lfp_var.History;
history{end+1,1} = datestr(clock);
history{end,2} = ['Add file ' filename ' to the structure'];

%% create output structure
lfp_out = lfp_var;
lfp_out.Trial = [lfp_var.Trial trial]; % concatenate trials
lfp_out.History = history;

end

