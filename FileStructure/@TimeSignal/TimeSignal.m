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
        
        function self = TimeSignal(varargin)
            subclassFlag = 0;
            indicesVarargin = []; % initiate vector for superclass constructor
            indTime = [];
            indEvents = [];
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'time'
                            indTime = i_argin + 1;
                        case 'events'
                            indEvents = i_argin + 1;
                        case 'subclassflag'
                            subclassFlag = varargin{i_argin + 1};
                        otherwise
                            indicesVarargin = [indicesVarargin i_argin i_argin+1];
                    end
                end
            end                
            self@Signal(varargin{indicesVarargin}, 'subclassFlag', 1);
            if ~isempty(indTime), self.Time = varargin{indTime};end
            if ~isempty(indEvents), self.Events = varargin{indEvents};end
            if ~subclassFlag
                self.History{end+1,1} = datestr(clock);
                self.History{end,2} = 'Calling TimeSignal constructor';
                self = self.setDefaults;
                self.checkInstance;
            end
        end
        
        
        %% set, get and check methods
        
        % set time
        function self = set.Time(self, time)
            if ~isnumeric(time) || ~isvector(time)
                error('''Time'' property must be set as a numeric vector');
            end
            self.Time = time;
        end
        
        % set default values
        function self = setDefaults(self)
            self = self.setDefaultChannelTags;
            self = self.setDefaultDimOrder;
            self = self.setDefaultTime;
        end
        
        % set default DimOrder property
        function self = setDefaultDimOrder(self)
            if isempty(self.DimOrder)
                nDims = ndims(self.Data);
                self.DimOrder{1} = 'time';
                self.DimOrder(2:nDims-1) = arrayfun(@(x) ['dim' num2str(x)],2:nDims-1,'UniformOutput',0); % for optional supplementary dimensions but not advised. Create a subclass if nDims > 2 is necessary
                self.DimOrder{nDims} = 'chan';
            end
        end
        
        % set default Time property
        function self = setDefaultTime(self)
            if isempty(self.Time)
                nSamplesTime = size(self.Data, 1);
                self.Time = 0:nSamplesTime-1;
                warning('Time property has been set at default value, ie. 0:nSamples-1');
            end
        end
                
        % check instance properties
        function checkInstance(self)
            self.checkData;
            self.checkChannelTags;
            self.checkDimOrder;
            self.checkTime;
        end
        
        % check DimOrder property
        function checkDimOrder(self)
            if size(self.DimOrder,2) ~= ndims(self.Data)
                error('the number of dimensions in DimOrder property does not correspond to the number of dimensions in Data property');
            end
            if ~strcmpi(self.DimOrder{1},'time') || ~strcmpi(self.DimOrder{end},'chan')
                error('1st dimension in DimOrder property must be ''time'' and last must be ''chan''');
            end
        end
        
        % check Time property
        function checkTime(self)
            if size(self.Time, 2) ~= size(self.Data, self.dimIndex('time'))
                error(['Time property and dimension ' num2str(self.dimIndex('time')) ' of Data property should be the same length']);
            end
        end
        
        
        
        %% other methods
        

        %% external methods
        
        timeWindowedSignal = timeWindow(thisObj, minTime, maxTime)
        
        
    end
end