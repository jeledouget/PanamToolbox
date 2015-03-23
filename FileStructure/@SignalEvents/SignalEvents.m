classdef SignalEvents
    %SIGNALEVENTS class defines a set of events for a trial or a set of trials
    
    
    
    properties
        Time;
        SupplInfo@containers.Map
    end
    
    
    
    methods
        
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

