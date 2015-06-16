% Method for class 'TimeFreqSignal' and subclasses
% interpFreq : interpolate data to another vector of freq samples
% INPUTS
% OUTPUT
    % interpSignal :  freq-interpolated 'TimeFreqSignal' object
    
    
function interpSignal = interpTimeFreq(self, newTime, newFreq, varargin)

interpSignal = self;

% dims
nDims = ndims(self.Data);
sizes = size(self.Data);
dimTime = self.dimIndex('time');
oldTime = self.Time;
dimFreq = self.dimIndex('freq');
oldFreq = self.Freq;
[oT, oF] = meshgrid(oldTime, oldFreq);
[nT, nF] = meshgrid(newTime, newFreq);
data = permute(self.Data, [dimFreq dimTime setdiff(1:nDims, [dimFreq dimTime])]);
if isempty(varargin), varargin = {'linear','extrap'};end
for ii = 1:numel(data)/length(oldTime)/length(oldFreq)
    interpData(:,:,ii) = interp2(oT, oF, data(:,:,ii), nT, nF, varargin{:});
end
interpData = reshape(interpData,[length(newFreq) length(newTime) sizes(setdiff(1:nDims, [dimFreq dimTime]))]);

% affect changes
if dimTime < dimFreq
    interpSignal.Data = permute(interpData, [3:dimTime+1 2 dimTime+2:dimFreq 1 dimFreq+1:nDims]);
else
    interpSignal.Data = permute(interpData, [3:dimFreq+1 1 dimFreq+2:dimTime 2 dimTime+1:nDims]);
end
interpSignal.Freq = newFreq;
interpSignal.Time = newTime;

% history
interpSignal.History{end+1,1} = datestr(clock);
interpSignal.History{end,2} = ...
        'Interpolate data to new time and frequency vectors';

end