% Method for class 'TimeSignal' and subclasses. For scalar TimeSignal
% object only
%  offsetTime : offset the time by a certain amount
% INPUTS
    % minTime : time to begin the trial
    % maxTime : time to end to trial
% OUTPUT
    % offsetSignal :  time-windowed 'TimeSignal' object

    
    
function offsetSignal = offsetTime(self, offset, varargin)


% offset the time
offsetSignal = self;
ev = offsetSignal.Events;
[offsetSignal.Events, offTime] = ev.offsetTime(offset, varargin{:});
offsetSignal.Time = offsetSignal.Time - offTime;

% history
offsetSignal.History{end+1,1} = datestr(clock);
offsetSignal.History{end,2} = ...
        'Apply an offset to the Time of the Signal';

end
