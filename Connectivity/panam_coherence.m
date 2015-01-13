function outputStruct= panam_coherence( inputStruct, param)
%PANAM_COHERENCE Compute the coherence of a signal (including a set of
%trials)

% INPUT: inputStruct : panam-data structure (LFP or other)
% OUTPUT:  outputStruct : panam coherence structure


%% fourier transforms

% cfg
cfg = [];
cfg.output     = 'fourier';
cfg.method     = 'mtmfft';
cfg.foi     = 1:100;
cfg.tapsmofrq  = 2;
cfg.keeptrials = 'yes';
cfg.channel    = inputStruct.Trials(1).PreProcessed.Tag;

% data prep
data.label = inputStruct.Trials(1).PreProcessed.Tag;
for i=1:length(inputStruct.Trials)
    data.trial{i} = inputStruct.Trials(i).PreProcessed.Data;
    data.time{i} = inputStruct.Trials(i).PreProcessed.Time;
    trialName{i} = inputStruct.Trials(i).PreProcessed.TrialName;
    trialNum(i) = inputStruct.Trials(i).PreProcessed.TrialNum;
end
freqfourier    = ft_freqanalysis(cfg, data);

%% coherence

cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = 'all';
fdfourier      = ft_connectivityanalysis(cfg, freqfourier);


%% output
outputStruct.coherence = fdfourier;


end

