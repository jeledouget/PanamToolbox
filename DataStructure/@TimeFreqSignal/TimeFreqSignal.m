classdef TimeFreqSignal < TimeSignal & FreqSignal
    
    % TIMEFREQSIGNAL Class for time-frequency representations
    % 1st Dimension of Data property is for time
    % 2nd Dimension of Data property is for freq
    % last dimension is for channels
    
    
    
    %% properties
    
    properties
        
    end
    
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = TimeFreqSignal(varargin)
            subclassFlag = 0; % default : not called from  a subclass constructor
            indicesVarargin = []; % initiate vector for superclass constructor
            indFreq = []; % default value for freq
            indFreqMarkers = [];
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'freq'
                            indFreq = i_argin + 1;
                        case 'freqmarkers'
                            indFreqMarkers = i_argin + 1;
                        case 'subclassflag'
                            subclassFlag = varargin{i_argin + 1};
                        otherwise
                            indicesVarargin = [indicesVarargin i_argin i_argin+1];
                    end
                end
            end
            argFreqSignal = {'subclassFlag',1};
            if ~isempty(indFreq)
                argFreqSignal = [argFreqSignal, 'freq',varargin{indFreq}];
            end
            if ~isempty(indFreqMarkers)
                argFreqSignal = [argFreqSignal, 'freqmarkers', varargin(indFreqMarkers)];
            end
            self@FreqSignal(argFreqSignal{:});
            self@TimeSignal(varargin{indicesVarargin},'subclassFlag',1);
            if ~subclassFlag  && ~isempty(varargin)% only if the constructor is not called from a subclass
                self.History{end+1,1} = datestr(clock);
                self.History{end,2} = 'Calling TimeFreqSignal constructor';
                self = self.setDefaults;
                self.checkInstance;
            end
        end
        
        
        %% set, get and check methods
        
        % set default values
        function self = setDefaults(self)
            self = self.setDefaultChannelTags;
            self = self.setDefaultDimOrder;
            self = self.setDefaultTime;
            self = self.setDefaultFreq;
        end
        
        % set default DimOrder property
        function self = setDefaultDimOrder(self)
            if isempty(self.DimOrder)
                nDims = ndims(self.Data);
                self.DimOrder{1} = 'time';
                self.DimOrder{2} = 'freq';
                self.DimOrder(3:nDims-1) = arrayfun(@(x) ['dim' num2str(x)],3:nDims-1,'UniformOutput',0); % for optional supplementary dimensions but not advised. Create a subclass if nDims > 3 is necessary
                self.DimOrder{nDims} = 'chan';
            end
        end
         
        % set default Freq property
        function self = setDefaultFreq(self)
            if isempty(self.Freq)
                nSamplesFreq = size(self.Data, 2);
                self.Freq = 0:nSamplesFreq-1;
                warning('Freq property has been set at default value, ie. 0:nSamples-1');
            end
        end
        
        % check instance properties
        function checkInstance(self)
%             self.checkData;
            self.checkChannelTags;
            self.checkDimOrder;
            self.checkTime;
            self.checkFreq;
        end
        
        % check Data property
        function checkData(self)
            self.checkData@Signal;
            if ndims(self.Data) < 3
                error('the number of dimensions in Data for TimeFreqSignal instances must be >=3');
            end
        end
        
        % check DimOrder property
        function checkDimOrder(self)
            if size(self.DimOrder,2) ~= ndims(self.Data)
                error('the number of dimensions in DimOrder property does not correspond to the number of dimensions in Data property');
            end
            if ~strcmpi(self.DimOrder{1},'time') || ~strcmpi(self.DimOrder{2},'freq') || ~strcmpi(self.DimOrder{end},'chan')
                error('1st dimension in DimOrder property must be ''time'', 2nd must be ''freq'' and last must be ''chan''');
            end
        end
        
        
        %% other methods
        
        % plot
        function h = colorSubplots(self, varargin)
            h = self.subplots(varargin{:});
        end
        function h = colorPlot(self, varargin)
            h = self.plot(varargin{:});
        end
        
                
        %% external methods
        
        newSignal = concatenate(self, otherSignals, dim, subclassFlag)
        avgSignal = avgElements(self)
        freqSignal = toFreq(self, time, varargin)
        timeSignal = toTime(self, freq, varargin)
        ftStruct = toFieldTrip(self, varargin)
        
        % to do
        h = plot(self, commonOptions, specificOptions, varargin)
        h = subplots(self, commonOptions, specificOptions, varargin)
               
    end
end