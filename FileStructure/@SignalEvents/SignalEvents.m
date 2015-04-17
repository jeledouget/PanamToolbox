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
        Duration; % duration of events
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
            self = self.setDefaults;
        end
        
        
        %% set, get and check methods
        
        % set Time property
        function self = set.Time(self, time)
            if isnumeric(time) && isvector(time)
                self.Time = time;
            else
                error('time must be a numeric vector');
            end
        end
        
        % set Duration property
        function self = set.Duration(self, duration)
            if isnumeric(duration) && isvector(duration)
                self.Duration = duration;
            else
                error('duration must be a numeric vector');
            end
        end
        
        % set defaults values
        function self = setDefaults(self)
            self = self.setDefaultDuration;
        end
        
        % set default value for Duration property to 0 for each event
        function self = setDefaultDuration(self)
            self.Duration = zeros(1, size(self.Time,2));
        end
        
        % check instance
        function checkInstance(self)
            self.checkDuration;
        end
        
        % check Duration property
        function checkDuration(self)
            if size(self.Time,2) ~= size(self.Duration,2)
                error('Time and Duration properties for class SignalEvents must be numeric vectors with same length');
            end
        end
        
        
        %% other methods
        
        
        %% external methods
        
        % to do
        event = offsetTime(self, offset);
        
        
    end
    
    
end

