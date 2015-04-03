% Method for class 'TimeSignal' and subclasses
%  timeWindow : restrain the time course of the 'Signal' object to the
%  period between 'minTime' and 'maxTime'
% INPUTS
    % minTime : time to begin the trial
    % maxTime : time to end to trial
% OUTPUT
    % timeWindowedSignal :  time-windowed 'TimeSignal' object

    
    
function timeWindowedSignal = timeWindow(self, minTime, maxTime)

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
minSample = panam_closest(self.Time, minTime);
maxSample = panam_closest(self.Time, maxTime);
timeWindowedSignal.Time = timeWindowedSignal.Time(1,minSample:maxSample);
dims = size(timeWindowedSignal.Data);
dims(1) = maxSample - minSample + 1;
timeWindowedSignal.Data = reshape(timeWindowedSignal.Data(minSample:maxSample,:), dims);

% history
timeWindowedSignal.History{end+1,1} = datestr(clock);
timeWindowedSignal.History{end,2} = ...
        ['Time Windowing the signal : from ' num2str(minTime) 's to ' num2str(maxTime) 's'];

end
