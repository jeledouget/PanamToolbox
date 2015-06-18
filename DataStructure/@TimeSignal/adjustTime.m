% Method for class 'TimeSignal' and subclasses
%  adjustTime : for muti-elements TimeSignal, make it that all elements
%  have the same Time axis. Useful before averaging for example
% INPUTS
% OUTPUT



function adjustedSignal = adjustTime(self, varargin)

% check that Time property is numeric
if ~all(arrayfun(@isNumTime, self))
    error('adjustTime method only applies to TimeSignal objects with a numeric Time property');
end

% copy of the object
adjustedSignal = self;

% check that it is not already adjusted, and compute times
minAll = arrayfun(@(x) x.Time(1), self(:));
maxAll =  arrayfun(@(x) x.Time(end), self(:));
if length(unique(minAll)) == 1 && length(unique(maxAll)) == 1
    warning('object is already time-adjusted');
    return;
else
    minTime = max(minAll);
    maxTime = min(maxAll);
end

% time-windowing
adjustedSignal = adjustedSignal.timeWindow(minTime, maxTime, 'inf');
if ~isequal(adjustedSignal.Time)
    adjustedSignal = adjustedSignal.interpTime(adjustedSignal(1).Time);
end

% history
for ii = 1:numel(adjustedSignal)
    adjustedSignal(ii).History{end+1,1} = datestr(clock);
    adjustedSignal(ii).History{end,2} = ...
        ['Signal time-adjusted from ' num2str(minTime) 's to ' num2str(maxTime) 's'];
end
end
