% Method for class 'TimeSignal' and subclasses.
% For scalar TimeSignal only
% epochingFromEvents : separate a Signal into a set of Signals from events, times,
% etc...
% INPUTS
    % minTime : time to begin the trial
    % maxTime : time to end to trial
% OUTPUT
    % epochedSignal : epoched 'TimeSignal' object

    
    
function epochedSignal = epochingFromEvents(self, eventname,varargin)

% make self a column
self = self(:);
for ii = 1:numel(self)
    self(ii).Events = self(ii).Events.sortByTime;
end

% epoch
epochedSignal = self.empty;
for ii = 1:numel(self)
    % get times of start and finish
    ev = self(ii).Events;
    indEvent1 = find(strcmpi({ev.EventName},eventname1));
    if isnumeric(varargin{1})
        delay = varargin{1}; % time around the event, eg. [-1 2]
        times1 = [ev(indEvent1).Time] + delay(1);
        times2 = [ev(indEvent1).Time] + delay(2);
    else
        
    end
                
    
   epochedSignal(end+1);
end

% history
epochedSignal.History{end+1,1} = datestr(clock);
epochedSignal.History{end,2} = ...
        'Epoch the Signal';

end
