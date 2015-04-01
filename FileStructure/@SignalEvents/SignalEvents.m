classdef SignalEvents
    
    %SIGNALEVENTS : defines a set of events with a common name
    %
    % Properties:
    % Time = time vector - start time of the Events
    % EventName = event id
    % SupplInfo = containers.Map including optional information for the Event
    
    
    
    %% properties
    
    properties
        Time = 0; % time vector - start times of the events
        Duration = 0; % duration of events
        EventName@char = 'DefaultEvent'; % event id
        SupplInfo@containers.Map = containers.Map; % include optional information for the Event
    end
    
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = SignalEvents(eventname, time, duration, supplinfo)
            if nargin > 3
                self.SupplInfo = supplinfo;
            end
            if nargin > 2 && ~isempty(duration)
                self.Duration = duration;
            end
            if nargin > 1 && ~isempty(time)
                self.Time = time;
            end
            if nargin > 0 && ~isempty(eventname)
                self.EventName = eventname;
            end
%             self.checkInstance;
        end
        
        
        %% set, get and check methods
        
        % set time
        function self = set.Time(self, time)
            if isnumeric(time) && isvector(time)
                self.Time = time;
            else
                error('time must be a numeric vector');
            end
        end
        
        % set duration
        function self = set.Duration(self, duration)
            if isnumeric(duration) && isvector(duration)
                self.Duration = duration;
            else
                error('duration must be a numeric vector');
            end
        end
        
        
        %% other methods
        
        
        %% external methods
        
        % to do
        checkInstance(self);
        event = offsetTime(self, offset);
        
        
    end
    
    
end

