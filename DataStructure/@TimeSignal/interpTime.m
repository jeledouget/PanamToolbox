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

% case of 'replace' : just change the time vector. Must be the same
% length
if ~isempty(varargin) && strcmpi(varargin{1}, 'replace')
    timeSamples = unique(arrayfun(@(x) numel(x.Time), self));
    if numel(timeSamples) > 1 || timeSamples ~= numel(newTime)
        error(' to replace time vector, all elements must have the same number of time samples and the new time vector must also be the same length');
    end
    for ii = 1:numel(self)
        interpSignal(ii).Time = newTime;
        
        % handle markers
        interpSignal(ii).Events = interpSignal(ii).Events.asList;
        indToRemove = arrayfun(@(x) (x.Time > newTime(end) || x.Time < newTime(1)), interpSignal(ii).Events);
        interpSignal(ii).Events(indToRemove) = [];
        
        % history
        interpSignal(ii).History{end+1,1} = datestr(clock);
        interpSignal(ii).History{end,2} = ...
            'Interpolate data to a new time vector : replace';
    end
    return;
elseif ~isempty(varargin) && strcmpi(varargin{1}, 'interp1') % use interp1 function
    % compute
    for ii = 1:numel(self)
        % dims
        nDims = ndims(self(ii).Data);
        dimTime = self(ii).dimIndex('time');
        oldTime = self(ii).Time;
        data = permute(self(ii).Data, [dimTime 1:dimTime-1 dimTime+1:nDims]);
        if isempty(varargin)
            data = interp1(oldTime, data, newTime);
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
        interpSignal(ii).Events = interpSignal(ii).Events.asList;
        indToRemove = arrayfun(@(x) (x.Time > newTime(end) || x.Time < newTime(1)), interpSignal(ii).Events);
        interpSignal(ii).Events(indToRemove) = [];
        
        % history
        interpSignal(ii).History{end+1,1} = datestr(clock);
        interpSignal(ii).History{end,2} = ...
            'Interpolate data to a new time vector : interp1';
    end
    
else % use panam_interpMatrix
    % compute
    for ii = 1:numel(self)
        % dims
        nDims = ndims(self(ii).Data);
        dimTime = self(ii).dimIndex('time');
        oldTime = self(ii).Time;
        data = permute(self(ii).Data, [dimTime 1:dimTime-1 dimTime+1:nDims]);
        s = size(data);
        data = reshape(data, s(1), []);
        iM = panam_interpMatrix(oldTime, newTime, varargin{:}); % interpolation matrix
        data = iM' * data;
        data = reshape(data, [numel(newTime) s(2:end)]);
        
        % affect changes
        interpSignal(ii).Data = permute(data, [2:dimTime 1 dimTime+1:nDims]);
        interpSignal(ii).Time = newTime;
        
        % handle events
        interpSignal(ii).Events = interpSignal(ii).Events.asList;
        indToRemove = arrayfun(@(x) (x.Time > newTime(end) || x.Time < newTime(1)), interpSignal(ii).Events);
        interpSignal(ii).Events(indToRemove) = [];
        
        % history
        interpSignal(ii).History{end+1,1} = datestr(clock);
        interpSignal(ii).History{end,2} = ...
            'Interpolate data to a new time vector : panam_interpMatrix';
    end
end
 

if isa(self, 'SampledTimeSignal')
    interpSignal = interpSignal.sampledOrNot;
end
        
    
end
