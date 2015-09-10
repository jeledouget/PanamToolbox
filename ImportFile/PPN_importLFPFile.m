%GBMOV_IMPORTLFPFILE
% Import acquisition file into a Signal structure
% INPUTS
% filename : name of the file (full or in current directory)
% acquisitionType : MSup, RealGait, etc...
% extension : if necessary, type the extension of the file (Poly5,
% etc
% OUTPUT
% outSignal : Signal object created by the import

function outSignalSet = PPN_importLFPFile(filename, acquisition)

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
protocole = 'PPN';

% session
if strcmpi(type, 'LFP')
    session = 'POSTOP';
else
    session = 'UNKNOWN';
end


switch lower(extension)
    case '.edf'
        fs = hdr.samples(1)/ hdr.duration;
        try units = hdr.units(end-5:end);end
        data = data_temp(end-5:end,:)';
    case '.trc'
        fs = hdr.Rate_Min;
        try units = hdr.units(end-5:end);end
        data = data_temp(end-5:end,:)';
end


% sampling frequency
time = 1/fs*(0:size(data_temp,2)-1);

% channel tags
channelTags = {'C_01D', 'C_12D', 'C_23D', 'C_01G', 'C_12G', 'C_23G'};


tmp = inputdlg({'Subject Code','Speed Condition'},...
    'Check parameters of the input',1, {'',''});

subjectCode = tmp{1};
try speedCondition = tmp{2};end
try subjectNumber = str2num(subjectCode(end-1:end));end

% output file name
switch lower(acquisition)
    case 'realgait'
        fileNameOut = [protocole '_' session '_' subjectCode '_' speedCondition '_' acquisition];
    case {'gng', 'alerte'}
         fileNameOut = [acquisition '_' session '_' subjectCode '_' medCondition];
    case 'rest'
        fileNameOut = [protocole '_' session '_' subjectCode  '_' medCondition '_' acquisition];
    otherwise
        fileNameOut = [protocole '_' session '_' subjectCode  '_' medCondition];
end

% fill infos 
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
    try infosSet.comment = ['import ' sprintf('%s, ', protocole, acquisition, type, session, subjectCode) speedCondition];end
else
    try infosSet.comment = ['import ' sprintf('%s, ', protocole, acquisition, type, session) subjectCode];end
end


% triggers
trigg_Channel = 1;
trigg  = data_temp(trigg_Channel,:);
trigg_binary = clean_trigger_v2(trigg,fs);
trigg_samples = find(trigg_binary);
trig=trigg_samples(1);
for ii = 2:length(trigg_samples)
    if trigg_samples(ii)~=trigg_samples(ii-1)+1
        trig(end+1) = trigg_samples(ii);
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

