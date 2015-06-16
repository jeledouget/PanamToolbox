% Method for class 'SampledTimeSignal'
% Compute the time-frequency power spectrum by the input method of your choice
% INPUTS
    % newFreq : new sampling frequency
% OUTPUT
    % tfSignal : resampled 'Signal' object



function tfSignal = tfPowerSpectrum(self, varargin)

% method
if ~isempty(varargin)
    if ischar(varargin{1}) % the selected method is specified
        method = varargin{1};
        args = varargin(2:end);
    end
else % default
    method = 'fieldtrip';
    args = varargin;
end
    
% compute
switch lower(method)
    % use of FieldTrip's ft_freqanalysis function
    case 'fieldtrip'
        ftStructIn = self.toFieldTrip;
        ftStructOut = ft_freqanalysis(cfg, ftStructIn);
        tfSignal = panam_ftToSignal(ftStructOut);
        for ii = 1:numel(tfSignal)
            tfSignal(ii).Events = self(ii).Events;
            tfSignal(ii).Infos = self(ii).Infos;
        end
end

% history
for ii = 1:numel(tfSignal)
    tfSignal(ii).History{end+1,1} = datestr(clock);
    tfSignal(ii).History{end,2} = ...
        'Compute time-frequency power spectrum';
end

end

