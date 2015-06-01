classdef FreqMarkers
    
    % FREQMARKERS : defines a set of markers with a common name
    %
    % Properties:
    % Time = time vector - start time of the Events
    % Duration = duration of each event
    % EventName = event id
    % Info = containers.Map including optional information for the Event
    
    
    
    %% properties
    
    properties
        Freq = 0; % time vector - start times of the events
        MarkerName@char = ''; % event id
        Info@containers.Map = containers.Map; % include optional information for the Event
    end
    
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = FreqMarkers(markername, freq, info)
            if nargin > 2
                self.Info = info;
            end
            if nargin > 1 && ~isempty(freq)
                self.Freq = freq;
            end
            if nargin > 0 && ~isempty(markername)
                self.MarkerName = markername;
            end
            self = self.setDefaults;
        end
        
        
        %% set, get and check methods
        
        % set Time property
        function self = set.Freq(self, freq)
            if isnumeric(freq) && isvector(freq)
                self.Freq = freq;
            else
                error('freq must be a numeric vector');
            end
        end
        
        % set defaults values
        function self = setDefaults(self)
        end
        
        % check instance
        function checkInstance(self) %#ok<MANU>
        end
                
        
        %% other methods
        
        
        %% external methods
        
        newEvents = unifyMarkers(self, uniqueFreq)
        newMarkers = avgMarkers(self)      
        
    end
    
    
end

