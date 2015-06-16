% Method for class 'TimeFreqSignal' and subclasses
% interpTimeFreq : interpolate data to other vectors of time and freq samples
% INPUTS
% OUTPUT
    % interpSignal :  freq-interpolated 'FreqSignal' object
    
    
function interpSignal = interpFreq(self, newFreq, varargin)

interpSignal = self;

% dims
nDims = ndims(self.Data);
dimFreq = self.dimIndex('freq');
oldFreq = self.Freq;
data = permute(self.Data, [dimFreq 1:dimFreq-1 dimFreq+1:nDims]);
if isempty(varargin)
    data = interp1(oldFreq, data, newFreq,'linear','extrap');
else
    data = interp1(oldFreq, data, newFreq, varargin{:});
end

% affect changes
interpSignal.Data = permute(data, [2:dimFreq 1 dimFreq+1:nDims]);
interpSignal.Freq = newFreq;

% history
interpSignal.History{end+1,1} = datestr(clock);
interpSignal.History{end,2} = ...
        'Interpolate data to a new frequency vector';

end

