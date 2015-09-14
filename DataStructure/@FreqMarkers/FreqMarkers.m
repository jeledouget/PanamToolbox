classdef FreqMarkers
    
    % FREQMARKERS : defines a set of markers with a common name
    %
    % Properties:
    % Time = time vector - start time of the Events
    % Duration = duration of each event
    % EventName = event id
    % Infos = containers.Map including optional information for the Event
    
    
    
    %% properties
    
    properties
        Freq = 0; % freq vector - indicates the frequency of the marker or the start of the band (if used with window property)
        Window = 0; % width of the window of the marker
        MarkerName@char = ''; % event id
        Infos@struct;% include optional information for the marker
    end
    
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = FreqMarkers(markername, freq, window, infos)
            if nargin > 3
                self.Infos = infos;
            end
            if nargin > 2
                self.Window = window;
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
        
        % set Freq property
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
        listedMarkers = asList(self)
        newMarkers = deleteMarkers(self, varargin)
        sortedMarkers = sortByFreq(self)
        
        
    end
    
    
end

