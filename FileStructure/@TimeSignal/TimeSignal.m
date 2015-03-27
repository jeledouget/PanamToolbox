classdef TimeSignal < Signal
    
    % TIMESIGNAL Class for signal with time dimension
    %
    % Properties:
    % Events = container in which keys are events id (triggers, etc.) and values are instances of SignalEvents array
    % Time = numeric vector for time samples
    
    
    
    
    %% properties
    properties
        Events@containers.Map = containers.Map; % container in which keys are events id (triggers, etc.) and values are instances of SignalEvents array
        Time; % numeric vector for time samples
    end
    
    %% methods
    
    methods
        
        % constructor
        function self = TimeSignal(data, varargin)
            indicesVarargin = []; % indices fof varargin to call in superclass constructor, Signal here
            time = 0:size(data,1)-1; % default value for time
            events = containers.Map;
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'time'
                            time = varargin{i_argin + 1};
                        case 'events'
                            events = varargin{i_argin + 1};
                        otherwise
                            indicesVarargin = [indicesVarargin i_argin i_argin+1];
                    end
                end
            end                
            self@Signal('data',data,varargin{indicesVarargin});
            self.Time = time;
            self.Events = events;
            self.History{end+1,1} = datestr(clock);
            self.History{end,2} = 'Calling TimeSignal constructor';
        end
        
        % set time
        function self = set.Time(self, time)
            if ~isnumeric(time) || ~isvector(time)
                error('''Time'' property must be set as a numeric vector');
            end
            self.Time = time;
        end
        
        % other methods
        timeWindowedSignal = TimeWindow(thisObj, minTime, maxTime)
        
    end
end