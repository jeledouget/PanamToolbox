% Method for class 'TimeSignal' and subclasses.
% For scalar TimeSignal only
% epochingFromEvents : separate a Signal into a set of Signals from events, times,
% etc...
% INPUTS
    % minTime : time to begin the trial
    % maxTime : time to end to trial
% OUTPUT
    % epochedSignal : epoched 'TimeSignal' object

    
    
function epochedSignal = epoching(self, eventname,varargin)

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
    indEvent1 = find(strcmpi({ev.EventName},eventname));
    if isnumeric(varargin{1})
        delay = varargin{1}; % time around the event, eg. [-1 2]
        if delay(1) > delay(2)
            error('to epoch around an event, delay must be an increasing vector of 2 numbers');
        end
        times1 = [ev(indEvent1).Time] + delay(1);
        times2 = [ev(indEvent1).Time] + delay(2);
    elseif ischar(varargin{1}) % epoch between 2 events
        if ~strcmpi(varargin{1}, eventname) % 2 different events
            indEvent2 = find(strcmpi({ev.EventName},varargin{1}));
            if length(varargin) > 1 && ~isempty(varargin{2})
                delay = varargin{2}; % time around the events, eg. [-1 2]
            else
                delay = [0 0];
            end
            times1 = [ev(indEvent1).Time] + delay(1);
            times2 = [ev(indEvent2).Time] + delay(2);
            % check times
            if length(times1) ~= length(times2) || any(times1 > times2)
                error('to epoch around events, there must be the sazme number of events of both types and times for 1st event (plus chosen delay) must be inferior to times for 2nd event (plus chosen delay)');
            end
        else % from one marker to the other: eg. args :  'Go, 'Go', [-2,4]
            if length(varargin) > 1 && ~isempty(varargin{2})
                delay = varargin{2}; % time around the events, eg. [-1 2]
            else
                delay = [0 0];
            end
            times1 = [ev(indEvent1).Time] + delay(1);
            times2 = times1(2:end);
            if length(varargin) > 2 && ~isempty(varargin{3})
                lastDelay = varargin{3};
            else
                lastDelay = 'end';
            end
            if strcmpi(lastDelay, 'end')
                times2(end+1) = self(ii).Time(end);
            elseif isnumeric(lastDelay) % delay
                times2(end+1) = times1(end) + lastDelay;
            else
                error('to epoch between successive identic events, optional input for last epoch must be the numeric delay from the last event or the string''end'' tto epoch as far as possible');
            end                
        end   
    end
   % apply epoch          
   for jj = 1:length(times1)
       epochedSignal(end+1) = self(ii).timeWindow(times1(jj), times2(jj),'inf').offsetTime(ev(indEvent1(jj)).Time);% history
       epochedSignal(end).History{end+1,1} = datestr(clock);
       epochedSignal(end).History{end,2} = ...
            'Epoch the Signal';
   end
end



end
