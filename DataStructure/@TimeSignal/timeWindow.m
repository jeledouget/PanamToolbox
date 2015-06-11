% Method for class 'TimeSignal' and subclasses
%  timeWindow : restrain the time course of the 'Signal' object to the
%  period between 'minTime' and 'maxTime'
% INPUTS
    % minTime : time to begin the trial
    % maxTime : time to end to trial
    % mode : mode of panam_closest : 'normal', 'inf' ou 'sup'
% OUTPUT
    % timeWindowedSignal :  time-windowed 'TimeSignal' object

    
    
function timeWindowedSignal = timeWindow(self, minTime, maxTime, mode)

if nargin < 3 || isempty(mode)
    mode = 'normal';
end

% check that Time property is numeric
if ~(self.isNumTime)
    error('timeWindow method only applies to TimeSignal objects with a numeric Time property');
end

% handle default params
if nargin < 2 || isempty(minTime)
    minTime = -Inf;
end
if nargin < 3 || isempty(maxTime)
    maxTime = +Inf;
end

% copy of the object
timeWindowedSignal = self;

% extract the time-window
minSample = panam_closest(self.Time, minTime, mode);
maxSample = panam_closest(self.Time, maxTime, mode);
timeWindowedSignal.Time = timeWindowedSignal.Time(1,minSample:maxSample);
dims = size(timeWindowedSignal.Data);
dims(1) = maxSample - minSample + 1;
timeWindowedSignal.Data = reshape(timeWindowedSignal.Data(minSample:maxSample,:), dims);

% handle events
timeWindowedSignal.Events = timeWindowedSignal.Events.asList;
indToRemove = arrayfun(@(x) (x.Time > maxTime || x.Time < minTime), timeWindowedSignal.Events);
timeWindowedSignal.Events(indToRemove) = [];

% history
timeWindowedSignal.History{end+1,1} = datestr(clock);
timeWindowedSignal.History{end,2} = ...
        ['Time Windowing the signal : from ' num2str(minTime) 's to ' num2str(maxTime) 's'];

end
