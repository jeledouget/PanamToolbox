%  TimeWindow : restrain the time course of the 'Signal' object to the
%  period between 'minTime' and 'maxTime'
% INPUTS
    % minTime : time to begin the trial
    % maxTime : time to end to trial
% OUTPUT
    % timeWindowedSignal :  time-windowed 'Signal' object

    
    
function timeWindowedSignal = TimeWindow(thisObj, minTime, maxTime)

% handle default params
if nargin < 2 || isempty(minTime)
    minTime = -Inf;
end
if nargin < 3 || isempty(maxTime)
    maxTime = +Inf;
end

% copy of the object
timeWindowedSignal = thisObj;

% extract the time-window
minSample = panam_closest(minTime);
maxSample = panam_closest(maxTime);
timeWindowedSignal.Time = timeWindowedSignal.Time(1,minSample:maxSample);
timeWindowedSignal.Data = timeWindowedSignal.Data(:,minSample:maxSample);

% history
zeroMeanSignal.History{end+1,1} = datestr(clock);
zeroMeanSignal.History{end,2} = ...
        ['Time Windowing the signal : from ' num2str(minTime) 's to ' num2str(maxTime) 's'];

end
