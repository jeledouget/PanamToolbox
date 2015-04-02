classdef TimeFreqSignal < TimeSignal & FreqSignal
    
    %TIMEFREQSIGNAL Class for time-frequency representations
    % 1st Dimension of Data property is for time
    % 2nd Dimension of Data property id for freq
    
    
    
    %% properties
    
    properties
%         Freq; % numeric vector for frequency samples, or cell array (eg. {'alpha','beta'})
    end
    
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = TimeFreqSignal(varargin)
            subclassFlag = 0; % default : not called from  a subclass constructor
            indicesVarargin = []; % initiate vector for superclass constructor
            indFreq = []; % default value for freq
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'freq'
                            indFreq = i_argin + 1;
                        case 'subclassflag'
                            subclassFlag = varargin{i_argin + 1};
                        otherwise
                            indicesVarargin = [indicesVarargin i_argin i_argin+1];
                    end
                end
            end
            self@FreqSignal('subclassFlag',1);
            self@TimeSignal(varargin{indicesVarargin},'subclassFlag',1);
            if ~isempty(indFreq), self.Freq = varargin{indFreq};end
            if ~subclassFlag % only if the constructor is not called from a subclass
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
            self.checkData;
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
        
        
        %% external methods
        
        
    end
end