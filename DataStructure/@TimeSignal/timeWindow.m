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

% check that Time property is numeric
if ~all(arrayfun(@isNumTime, self))
    error('timeWindow method only applies to TimeSignal objects with a numeric Time property');
end

% copy of the object
timeWindowedSignal = self;


% handle default params
if nargin < 2 || isempty(minTime)
    minTime = -Inf;
end
if nargin < 3 || isempty(maxTime)
    maxTime = +Inf;
end
if nargin < 4 || isempty(mode)
    mode = 'normal';
end
if ischar(mode)
    mode = {mode, mode};
end

% compute
for ii = 1:numel(self)
    % extract the time-window
    minSample = panam_closest(self(ii).Time, minTime, mode{1});
    maxSample = panam_closest(self(ii).Time, maxTime, mode{2});
    timeWindowedSignal(ii).Time = timeWindowedSignal(ii).Time(1,minSample:maxSample);
    dims = size(timeWindowedSignal(ii).Data);
    dims(1) = maxSample - minSample + 1;
    timeWindowedSignal(ii).Data = reshape(timeWindowedSignal(ii).Data(minSample:maxSample,:), dims);
    
    % handle events
    if ~isempty(timeWindowedSignal(ii).Events)
        timeWindowedSignal(ii).Events = timeWindowedSignal(ii).Events.asList;
        indToRemove = arrayfun(@(x) (x.Time > maxTime || x.Time < minTime), timeWindowedSignal(ii).Events);
        timeWindowedSignal(ii).Events(indToRemove) = [];
    end
    
    % history
    timeWindowedSignal(ii).History{end+1,1} = datestr(clock);
    timeWindowedSignal(ii).History{end,2} = ...
        ['Time Windowing the signal : from ' num2str(minTime) 's to ' num2str(maxTime) 's'];
end

end
