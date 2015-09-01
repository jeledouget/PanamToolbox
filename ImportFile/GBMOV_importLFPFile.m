%GBMOV_IMPORTLFPFILE
% Import acquisition file into a Signal structure
% INPUTS
% filename : name of the file (full or in current directory)
% acquisitionType : MSup, RealGait, etc...
% extension : if necessary, type the extension of the file (Poly5,
% etc
% OUTPUT
% outSignal : Signal object created by the import

function outSignalSet = GBMOV_importLFPFile(filename, acquisition)

% filename
if nargin < 1 || isempty(filename)
    [file, dir] = uigetfile({'*.Poly5';'*.trc';'*.edf'}, 'Select the file to import');
    filename = fullfile(dir, file);
end

% acquisition
acquisitionList = {'RealGait','RealGaitAI', 'VirtualGait', 'Rest', 'GNG', 'MSup', 'Alerte'};
if nargin < 2 || isempty(acquisition)
    choice = menu('Which acquisition ?', acquisitionList{:});
    acquisition = acquisitionList{choice};
else
    ind = strcmpi(acquisition, acquisitionList);
    acquisition = acquisitionList{ind};
end


% handle inputs
[~, ~, extension] = fileparts(filename);

% load the components of the  file : header and sampled recordings
switch lower(extension)
    case '.poly5'
        [hdr data_temp] = tms_read_to_edf_struct(filename);
        type = 'LFP';
    case '.edf'
        [hdr data_temp] = edfRead(filename);
        type = 'LFP';
    case '.trc'
        [hdr data_temp] = trc_read_lfp(filename);
        type = 'LFP';
end

% acquisition
if strcmpi(acquisition, 'MSup')
    acquisition = 'MSup';
elseif strcmpi(acquisition, 'RealGait')
    acquisition = 'RealGait';
elseif strcmpi(acquisition, 'RealGaitAI')
    acquisition = 'RealGaitAI';
elseif strcmpi(acquisition, 'VirtualGait')
    acquisition = 'VirtualGait';
elseif strcmpi(acquisition, 'Rest')
    acquisition = 'Rest';
elseif strcmpi(acquisition, 'GNG')
    acquisition = 'GNG';
elseif strcmpi(acquisition, 'Alerte')
    acquisition = 'ALERTE';
end

% acquisition = upper(acquisition);

% protocole
protocole = 'GBMOV';

% session
if strcmpi(type, 'LFP')
    session = 'POSTOP';
else
    session = 'UNKOWN';
end

% subjectCode
subjectCode = hdr.patientID;

% parse recordID
parseRecord = regexp(hdr.recordID,'_','split');

% sampling frequency
fs = hdr.fs;
time = 1/fs*(0:size(data_temp,2)-1);

% channel tags
channelTags = {'C_01D', 'C_12D', 'C_23D', 'C_01G', 'C_12G', 'C_23G'};

% units
units = hdr.units(2:end);

% medical condition
if any(strcmpi('ON',parseRecord))
    medCondition = 'ON';
elseif any(strcmpi('OFF',parseRecord))
    medCondition = 'OFF';
else
    medCondition = 'UNKNOWN';
end

% speed condition
if any(strcmpi(acquisition, {'RealGait', 'VirtualGait', 'RealGaitAI', 'Porte'}))
    if any(strcmpi('S',parseRecord))
        speedCondition = 'S';
    elseif any(strcmpi('R',parseRecord))
        speedCondition = 'R';
    else
        speedCondition = 'UNKNOWN';
    end
end

% hand used to perform the task
if any(strcmpi(acquisition, {'MSup', 'GNG', 'Alerte'}))
    choices =  {'Left', 'Right', 'Unknown'};
    side = menu('Which hand / side has been used by the patient for the task ?',choices{:});
    side = choices{side};
end

% check input parameters
if exist('speedCondition','var')
    tmp = inputdlg({'Subject Code','Med Condition','Speed Condition'},...
        'Check parameters of the input',1, {subjectCode, medCondition, speedCondition});
else
    tmp = inputdlg({'Subject Code','Med Condition'},...
        'Check parameters of the input',1, {subjectCode, medCondition});
end
subjectCode = tmp{1};
medCondition = tmp{2};
try speedCondition = tmp{3};end
try subjectNumber = str2num(subjectCode(end-1:end));end

% output file name
switch lower(acquisition)
    case 'realgait'
        fileNameOut = [protocole '_' session '_' subjectCode  '_' medCondition '_' speedCondition '_' acquisition];
    case {'gng', 'alerte'}
         fileNameOut = [acquisition '_' session '_' subjectCode '_' medCondition];
    case 'rest'
        fileNameOut = [protocole '_' session '_' subjectCode  '_' medCondition '_' acquisition];
    otherwise
        fileNameOut = [protocole '_' session '_' subjectCode  '_' medCondition];
end

% fill infos (containers.Map)
try infos.medCondition = medCondition;end
try infos.speedCondition = speedCondition;end
try infos.side = side;end
try infos.session = session;end
try infos.type = type;end
try infos.units = units;end
try infos.subject = subjectCode;end
try 
    if ~isempty(subjectNumber)
        infos.subjNumber = subjectNumber;
    else
        infos.subjNumber = nan;
    end
end

try infosSet.protocole = protocole;end
try infosSet.acquisition = acquisition;end
try infosSet.fileName = fileNameOut;end
if exist('speedCondition','var')
    try infosSet.comment = ['import ' sprintf('%s, ', protocole, acquisition, type, session, subjectCode, medCondition) speedCondition];end
else
    try infosSet.comment = ['import ' sprintf('%s, ', protocole, acquisition, type, session, subjectCode) medCondition];end
end

% data
data = data_temp(2:end,:)';

% triggers
data_trigg = data_temp(1,:);
temp_trigg = find(data_trigg(1,:)~=2);
trig=temp_trigg(1);
for ii = 2:length(temp_trigg)
    if temp_trigg(ii)~=temp_trigg(ii-1)+1
        trig(end+1) = temp_trigg(ii);
    end
end
trigInfos.description = 'Soung trigger';
for ii = 1:length(trig)
    events(ii) = SignalEvents('Trig', time(trig(ii)), 0, trigInfos);
end


% affect output
signal = SampledTimeSignal('data', data,'fs',fs, 'time', time, 'events', events, 'channeltags', channelTags, 'infos', infos);
outSignalSet = SetOfSignals('signals', signal, 'infos', infosSet);


end

