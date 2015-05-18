classdef FreqSignal < Signal
    
    % FREQSIGNAL Class for freq-sampled signal objects
    % A signal has a Data and Freq component
    % 1st Dimension of Data property is for freq
    %
    % Freq = numeric vector for frequency samples

    
    
    %% properties
    
    properties
        Freq; % numeric vector for frequency samples, or cell of freq tags
        FreqMarkers@FreqMarkers vector; % container in which keys are events id (triggers, etc.) and values are instances of SignalEvents array
    end
    
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = FreqSignal(varargin)
            subclassFlag = 0;
            indicesVarargin = []; % initiate vector for superclass constructor
            indFreq = [];
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
            % call Signal constructor
            self@Signal(varargin{indicesVarargin}, 'subclassFlag', 1);
            if ~isempty(indFreq), self.Freq = varargin{indFreq};end
            if ~isempty(indFreqMarkers), self.FreqMarkers = varargin{indFreqMarkers};end
            if ~subclassFlag
                self.History{end+1,1} = datestr(clock);
                self.History{end,2} = 'Calling FreqSignal constructor';
                self = self.setDefaults;
                self.checkInstance;
            end
        end
        
        
        %% set, get and check methods
        
        % set freq
        function self = set.Freq(self, freq)
            if ~(isnumeric(freq) && isvector(freq)) && ~(iscell(freq) && all(cellfun(@ischar, freq)))
                error('Freq property must be set as a numeric vector or a cell of freq tags of type char');
            end
            self.Freq = freq;
        end
        
        % set default values
        function self = setDefaults(self)
            self = self.setDefaultChannelTags;
            self = self.setDefaultDimOrder;
            self = self.setDefaultFreq;
        end
        
        % set default DimOrder property
        function self = setDefaultDimOrder(self)
            if isempty(self.DimOrder)
                nDims = ndims(self.Data);
                self.DimOrder{1} = 'freq';
                self.DimOrder(2:nDims-1) = arrayfun(@(x) ['dim' num2str(x)],2:nDims-1,'UniformOutput',0); % for optional supplementary dimensions but not advised. Create a subclass if nDims > 2 is necessary
                self.DimOrder{nDims} = 'chan';
            end
        end
        
        % set default Freq property
        function self = setDefaultFreq(self)
            if isempty(self.Freq)
                nSamplesFreq = size(self.Data, 1);
                self.Freq = 0:nSamplesFreq-1;
                warning('Freq property has been set at default value, ie. 0:nSamples-1');
            end
        end
        
        % check instance properties
        function checkInstance(self)
%             self.checkData;
            self.checkChannelTags;
            self.checkDimOrder;
            self.checkFreq;
        end
        
        % check DimOrder property
        function checkDimOrder(self)
            if size(self.DimOrder,2) ~= ndims(self.Data)
                error('the number of dimensions in DimOrder property does not correspond to the number of dimensions in Data property');
            end
            if ~strcmpi(self.DimOrder{1},'freq') || ~strcmpi(self.DimOrder{end},'chan')
                error('1st dimension in DimOrder property must be ''freq'' and last must be ''chan''');
            end
        end
        
        % check Freq property
        function checkFreq(self)
            if size(self.Freq, 2) ~= size(self.Data, self.dimIndex('freq'))
                error(['Freq property and dimension ' num2str(self.dimIndex('freq')) ' of Data property should be the same length']);
            end
        end
        
        
        %% other methods
        
        function isNum = isNumFreq(self)
            if isnumeric(self.Freq)
                isNum = 1;
            elseif iscell(self.Freq) && all(cellfun(@ischar, self.Freq))
                isNum = 0;
            else
                error('Freq property must be a numeric vector or a cell vector of type char');
            end
        end
        
        
        %% external methods
        
        freqWindowedSignal = freqWindow(self, minFreq, maxFreq)
        h = plot(self, commonOptions, specificOptions)
        h = subplots(self, commonOptions, specificOptions)
        avgSignal = avgFreq(self, freqBands, freqTags)
        newSignal = concatenate(self, otherSignals, dim, subclassFlag)
        
        % to do
        newSignal = average(self, options) % average elements of a FreqSignal matrix
        h = colorPlot(self, commonOptions, specificOptions, varargin)
        h = colorSubplots(self, commonOptions, specificOptions)
        
        
    end
end