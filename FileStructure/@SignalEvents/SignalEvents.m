classdef SignalEvents
    %SIGNALEVENTS class defines a set of events for a trial or a set of trials
    
    
    
    properties
        Time;
        EventName@char;
        SupplInfo@containers.Map = containers.Map;
    end
    
    
    
    methods
        
        % constructor
        function self = SignalEvents(time, eventname, supplinfo)
            self.SupplInfo = containers.Map;
            if nargin > 2
                self.SupplInfo = supplinfo;
            end
            if nargin > 1 && ~isempty(eventname)
                self.EventName = eventname;
            end
            if nargin > 0 && ~isempty(time)
                self.Time = time;
            end
        end
        
        % set time
        function self = set.Time(self, time)
            if isnumeric(time) && isvector(time)
                self.Time = time;
            else
                error('time must be a numeric vector');
            end
        end
        
        % to do
        event = offsetTime(self, offset);
    end
    
    
end

