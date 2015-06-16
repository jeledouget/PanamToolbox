% Method for class 'TimeSignal' and subclasses
%  interpTime : interpolate data to another vector of time samples
% INPUTS
% OUTPUT
    % interpSignal :  time-interpolated 'TimeSignal' object
% WARNING : SampledTimeSignal objects will have their sampling frequency recalculated, 
% or the object will be transformed in TimeSignal if no sampling frequency
% is applicable

    
    
function interpSignal = interpTime(self, newTime, varargin)

interpSignal = self;

% dims
nDims = ndims(self.Data);
dimTime = self.dimIndex('time');
oldTime = self.Time;
data = permute(self.Data, [dimTime 1:dimTime-1 dimTime+1:nDims]);
if isempty(varargin)
    data = interp1(oldTime, data, newTime,'linear','extrap');
else
    data = interp1(oldTime, data, newTime, varargin{:});
end

% affect changes
interpSignal.Data = permute(data, [2:dimTime 1 dimTime+1:nDims]);
interpSignal.Time = newTime;

if isa(self, 'SampledTimeSignal')
    interpSignal = interpSignal.sampledOrNot;
end

% history
interpSignal.History{end+1,1} = datestr(clock);
interpSignal.History{end,2} = ...
        'Interpolate data to a new time vector';

end
