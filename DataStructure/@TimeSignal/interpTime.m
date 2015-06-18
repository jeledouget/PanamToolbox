% Method for class 'TimeSignal' and subclasses
%  interpTime : interpolate data to another vector of time samples
% INPUTS
% OUTPUT
% interpSignal :  time-interpolated 'TimeSignal' object
% WARNING : SampledTimeSignal objects will have their sampling frequency recalculated,
% or the object will be transformed in TimeSignal if no sampling frequency
% is applicable



function interpSignal = interpTime(self, newTime, varargin)

% copy
interpSignal = self;

% compute
for ii = 1:numel(self)
    % dims
    nDims = ndims(self(ii).Data);
    dimTime = self(ii).dimIndex('time');
    oldTime = self(ii).Time;
    data = permute(self(ii).Data, [dimTime 1:dimTime-1 dimTime+1:nDims]);
    if isempty(varargin)
        data = interp1(oldTime, data, newTime,'linear','extrap');
    else
        data = interp1(oldTime, data, newTime, varargin{:});
    end
    
    % affect changes
    interpSignal(ii).Data = permute(data, [2:dimTime 1 dimTime+1:nDims]);
    interpSignal(ii).Time = newTime;
    
    if isa(self(ii), 'SampledTimeSignal')
        interpSignal(ii) = interpSignal(ii).sampledOrNot;
    end
    
    % handle events
    interpSignal.Events = interpSignal.Events.asList;
    indToRemove = arrayfun(@(x) (x.Time > newTime(end) || x.Time < newTime(1)), interpSignal.Events);
    interpSignal.Events(indToRemove) = [];
    
    % history
    interpSignal(ii).History{end+1,1} = datestr(clock);
    interpSignal(ii).History{end,2} = ...
        'Interpolate data to a new time vector';
end

end
