% Method for class 'TimeSignal' and subclasses.
% For scalar TimeSignal only
% epochingFromEvents : separate a Signal into a set of Signals from events, times,
% etc...
% INPUTS
% minTime : time to begin the trial
% maxTime : time to end to trial
% OUTPUT
% epochedSignal : epoched 'TimeSignal' object



function epochedSignal = epoching(self, eventname, varargin)

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
    if ~isempty(indEvent1)
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
                for jj = 1:numel(times1)
                    if jj < numel(times1)
                        ind2 = find(([ev(indEvent2).Time] > (times1(jj) - delay(1))) .*...
                            ([ev(indEvent2).Time] < (times1(jj+1) - delay(1))),...
                            1,'first'); % first event of second type after event of 1st type
                    else
                        ind2 = find(([ev(indEvent2).Time] > (times1(jj) - delay(1))),...
                            1,'first'); % first event of second type after event of 1st type
                    end
                    if ~isempty(ind2) && (ev(indEvent2(ind2)).Time + delay(2) > times1(jj));
                        times2(jj) = [ev(indEvent2(ind2)).Time] + delay(2);
                    else
                        times2(jj) = nan;
                    end
                end
                % delete when events are not good
                times1(isnan(times2)) = [];
                times2(isnan(times2)) = [];
            else % from one marker to the other: eg. args :  'Go, 'Go', [-2,4]
                if length(varargin) > 1 && ~isempty(varargin{2})
                    delay = varargin{2}; % time around the events, eg. [-1 2]
                else
                    delay = [0 0];
                end
                if length(varargin) > 2 && ~isempty(varargin{3})
                    maxLength = varargin{3};
                else
                    maxLength = +Inf;
                end
                times1 = [ev(indEvent1).Time] + delay(1);
                times2 = min(times1(1:end-1) + maxLength,times1(2:end) + delay(2));
                times2(end+1) = min(times1(end) + maxLength, self(ii).Time(end));
            end
        end
        % apply epoch
        for jj = 1:length(times1)
            try
                epochedSignal(end+1) = self(ii).timeWindow(times1(jj), times2(jj),'inf').offsetTime(ev(indEvent1(jj)).Time);% history
            catch
                epochedSignal(end+1) = self(ii).timeWindow(times1(jj), times2(jj),'normal').offsetTime(ev(indEvent1(jj)).Time);% history
            end
            epochedSignal(end).History{end+1,1} = datestr(clock);
            epochedSignal(end).History{end,2} = ...
                'Epoch the Signal';
        end
    end
end



end
