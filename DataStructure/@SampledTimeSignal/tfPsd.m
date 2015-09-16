% Method for class 'SampledTimeSignal'
% Compute the time-frequency power spectrum by the input method of your choice
% INPUTS
% OUTPUT



function tfSignal = tfPsd(self, varargin)

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
        defaultCfg.foi = 1:round(self(1).Fs/4);
        if isfield(varargin, 'windowspace')
            windowSpace = varargin.windowspace;
        else
            windowSpace = 0.02;
        end
        defaultCfg.tapsmofrq = 4;
        defaultCfg.taper = 'dpss';
        defaultCfg.output = 'pow';
        defaultCfg.keeptrials = 'yes';
        defaultCfg.pad = []; % padding = data length
        defaultCfg.verbose = 0;
        % adjust cfg
        if isfield(varargin, 'toi')
            if strcmpi(varargin.toi, 'min')
                tmpMin = max(arrayfun(@(x) x.Time(1), self));
                tmpMax = min(arrayfun(@(x) x.Time(end), self));
                defaultCfg.toi = tmpMin:windowSpace:tmpMax;
                varargin = rmfield(varargin, 'toi');
            elseif strcmpi(varargin.toi, 'max')
                % default behaviour
                varargin = rmfield(varargin, 'toi');
            end
        end
        cfg = setstructfields(defaultCfg, varargin);
        if ~isfield(cfg, 't_ftimwin')
           cfg.t_ftimwin = max([ones(1,length(cfg.foi)).*0.5 ; 3./cfg.foi]);
        end
        if isfield(cfg, 'foilim'), cfg = rmfield(cfg,'foi');end
        % compute via FieldTrip
        if strcmpi(cfg.keeptrials, 'no') || isfield(cfg, 'toi')
            ftStructIn = self.toFieldTrip;
            ftStructOut = ft_freqanalysis(cfg, ftStructIn);
            tfSignal = panam_ftToSignal(ftStructOut);
        else
            for ii = 1:numel(self)
                cfg.toi = self(ii).Time(1):windowSpace:self(ii).Time(end);
                ftStructIn{ii} = self(ii).toFieldTrip;
                ftStructOut{ii} = ft_freqanalysis(cfg, ftStructIn{ii});
                tfSignal(ii) = panam_ftToSignal(ftStructOut{ii});
            end
        end
        % events
        for ii = 1:numel(tfSignal)
            if isa(tfSignal(ii),'TimeSignal')
                tfSignal(ii).Events = self(ii).Events;
            end
            tfSignal(ii).Infos = self(ii).Infos;
            tfSignal(ii) = tfSignal(ii).interpFreq(cfg.foi, 'replace');
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

