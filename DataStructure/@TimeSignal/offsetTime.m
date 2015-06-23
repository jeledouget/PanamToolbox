% Method for class 'TimeSignal' and subclasses. For scalar TimeSignal
% object only
%  offsetTime : offset the time by a certain amount
% INPUTS
% minTime : time to begin the trial
% maxTime : time to end to trial
% OUTPUT
% offsetSignal :  time-windowed 'TimeSignal' object



function offsetSignal = offsetTime(self, offset, varargin)

% copy
offsetSignal = self;

for ii = 1:numel(self)
    % offset the time
    ev = offsetSignal(ii).Events;
    [offsetSignal(ii).Events, offTime] = ev.offsetTime(offset, varargin{:});
    offsetSignal(ii).Time = offsetSignal(ii).Time - offTime;
    
    % history
    offsetSignal(ii).History{end+1,1} = datestr(clock);
    offsetSignal(ii).History{end,2} = ...
        'Apply an offset to the Time of the Signal';
end

end
