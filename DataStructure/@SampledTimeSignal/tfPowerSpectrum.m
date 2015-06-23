% Method for class 'SampledTimeSignal'
% Compute the time-frequency power spectrum by the input method of your choice
% INPUTS
    % newFreq : new sampling frequency
% OUTPUT
    % tfSignal : resampled 'Signal' object



function tfSignal = tfPowerSpectrum(self, varargin)

% method
if ~isempty(varargin)
    if ischar(varargin{1}) % kvPairs
        toolInd = find(strcmpi(varargin, 'tool'));
        tool = varargin{toolInd+1};
        varargin(toolInd:toolInd+1) = [];
    elseif isstruct(varargin{1})  && isfield(varargin{1}, 'tool') % structure
        tool = varargin{1}.('tool');
    end
end
% default
if ~exist('tool','var') % default
    tool = 'fieldtrip';
end

% compute
switch lower(tool)
    % use of FieldTrip's ft_freqanalysis function
    case 'fieldtrip'
        % to FieldTrip
        ftStructIn = self.toFieldTrip;
        % args
        if ~isempty(varargin)
            if ischar(varargin{1}) % kvPairs
                varargin = panam_args2struct(varargin{:});
            else
                varargin = varargin{1};
            end
        else
            varargin = [];
        end
        % default cfg
        defaultCfg.method = 'mtmconvol';
        defaultCfg.foi = 1:round(self.Fs/4);
        tmpMin = max(arrayfun(@(x) x.Time(1), self));
        tmpMax = min(arrayfun(@(x) x.Time(end), self));
        if isfield(varargin, 'windowspace')
            windowSpace = varargin.windowspace;
        else
            windowSpace = 0.02;
        end
        defaultCfg.toi = tmpMin:windowSpace:tmpMax;
        defaultCfg.tapsmofrq = 4;
        defaultCfg.taper = 'dpss';
        defaultCfg.output = 'pow';
        defaultCfg.keeptrials = 'yes';
        defaultCfg.pad = []; % padding = data length
        defaultCfg.verbose = 0;
        % adjust cfg
        cfg = setstructfields(defaultCfg, varargin);
        if ~isfield(cfg, 't_ftimwin')
           cfg.t_ftimwin=  max([ones(1,length(cfg.foi)).*0.5 ; 3./cfg.foi]);
        end
        if isfield(cfg, 'foilim'), cfg = rmfield(cfg,'foi');end
        % compute
        ftStructOut = ft_freqanalysis(cfg, ftStructIn);
        tfSignal = panam_ftToSignal(ftStructOut);
        for ii = 1:numel(tfSignal)
            tfSignal(ii).Events = self(ii).Events;
            tfSignal(ii).Infos = self(ii).Infos;
            tfSignal(ii) = tfSignal(ii).interpFreq(cfg.foi);
        end
    otherwise
        error('method not implemented at the moment');
end

% history
for ii = 1:numel(tfSignal)
    tfSignal(ii).History{end+1,1} = datestr(clock);
    tfSignal(ii).History{end,2} = ...
        'Compute time-frequency power spectrum';
end

end

