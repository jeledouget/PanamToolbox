%GBMOV_IMPORTLFPFILE
% Import acquisition file into a Signal structure
% INPUTS
    % filename : name of the file (full or in current directory)
    % acquisitionType : MSup, RealGait, etc...
    % extension : if necessary, type the extension of the file (Poly5,
    % etc
% OUTPUT
    % outSignal : Signal object created by the import

function outSignal = GBMOV_importLFPFile(filename, acquisition)

% 
initialDir = pwd;

% handle inputs
[~, ~, extension] = fileparts(filename);

% load the components of the  file : header and sampled recordings
switch lower(extension)
    case 'poly5'
        [hdr data_temp] = tms_read_to_edf_struct(filename);
        type = 'LFP';
    case 'edf'
        [hdr data_temp] = edfRead(filename);
        type = 'LFP';
    case 'trc'
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
end
    
% infos
infos = containers.Map;

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
try subjectNumber = str2double(subjectCode(end-1:end));end

% parse recordID
parseRecord = regexp(hdr.recordID,'_','split');

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

% channel tags
channelTags = {'C_01D', 'C_12D', 'C_23D', 'C_01G', 'C_12G', 'C_23G'};
for ii = 1:length(tag)
    tag_channel(ii) = find(cellfun(@(x) all(ismember(tag{ii}(end-2:end), x)), hdr.label));
end

% units
units = {'uV', 'uV', 'uV', 'uV', 'uV', 'uV'};

% sampling frequency
fech = hdr.fs;

% output file name
fileNameOut = [protocole '_' session '_' subjectCode  '_' medCondition '_' type];

% fill containers.Map
try info('medCondition') = medCondition;end
try info('speedCondition') = speedCondition;end
try info('protocole') = protocole;end
try info('session') = session;end
try info('type') = type;end
try info('units') = units;end
try info('acquisition') = acquisition;end
try info('fileName') = fileNameOut;end
try info('subjCode') = subjectCode;end
try info('subjNumber') = subjectNumber;end

% check input parameters
tmp = inputdlg(infos.keys,'Check parameters of the input',1, infos.values);
ind = 1;
for k = info.keys
    info(k) = tmp{ind};
    ind = ind+1;
end

% data


end

