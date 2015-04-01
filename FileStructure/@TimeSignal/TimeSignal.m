classdef TimeSignal < Signal
    
    % TIMESIGNAL Class for signal with time dimension
    % 1st Dimension of Data property is for time
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
        
        %% constructor
        
        function self = TimeSignal(data, varargin)
            subclassFlag = 0;
            indicesVarargin = []; % initiate vector for superclass constructor
            time = 0:size(data,1)-1; % default value for time
            events = containers.Map;
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'time'
                            time = varargin{i_argin + 1};
                        case 'events'
                            events = varargin{i_argin + 1};
                        case 'subclassflag'
                            subclassFlag = varargin{i_argin + 1};
                        otherwise
                            indicesVarargin = [indicesVarargin i_argin i_argin+1];
                    end
                end
            end                
            self@Signal('data', data, varargin{indicesVarargin}, 'subclassFlag', 1);
            if isempty(self.DimOrder), self.DimOrder = {'time','chan'};end
            self.Time = time;
            self.Events = events;
            if ~subclassFlag
                self.History{end+1,1} = datestr(clock);
                self.History{end,2} = 'Calling TimeSignal constructor';
                self.setDefaults;
                self.checkInstance;
            end
        end
        
        
        %% set, get and check methods
        
        % set default values
        function self = setDefaults(self)
            
        end
        
        % check instance properties
        function checkInstance(self)
            
        end
        
        % set time
        function self = set.Time(self, time)
            if ~isnumeric(time) || ~isvector(time)
                error('''Time'' property must be set as a numeric vector');
            end
            self.Time = time;
        end
        
        
        %% other methods
        

        %% external methods
        
        timeWindowedSignal = TimeWindow(thisObj, minTime, maxTime)
        
        
    end
end