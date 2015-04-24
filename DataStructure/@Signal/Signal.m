classdef Signal
    
    % SIGNAL Class for signal objects
    %
    % Properties :
    % Data = numeric matrix with values of the signal
    % DimOrder = cell of strings with dimensions of the signal values (eg. {'time','channels'})
    % Infos = information about the signal (1 x 1 containers.Map) : can include TrialName, TrialNumber, Units, etc.;
    % History = history of operations on the Signal instance (n x 2 string cells)
    
    
    
    %% properties
    
    properties
        Data = []; % numeric matrix with values of the signal; see set.Data
        ChannelTags@cell vector = {}; % ids for last dimension of data (usually channels, eg. {'C01D','C12D'})
        DimOrder@cell vector = {}; % cell of strings with dimensions of the signal values (eg. {'time','channels'})
        Infos@containers.Map = containers.Map; % information about the signal (1 x 1 containers.Map) : can include TrialName, TrialNumber, Units, etc.;
        History@cell matrix; % history of operations on the Signal instance (n x 2 string cells)
    end
    
    properties(Hidden)
        Temp; % store temporary information
    end
    
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = Signal(varargin)
            subclassFlag = 0;
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'data'
                            self.Data = varargin{i_argin + 1};
                        case 'channeltags'
                            self.ChannelTags = varargin{i_argin + 1};
                        case 'dimorder'
                            self.DimOrder = varargin{i_argin + 1};
                        case 'infos'
                            self.Infos = varargin{i_argin + 1};
                        case 'subclassflag'
                            subclassFlag = varargin{i_argin + 1};
                        otherwise
                            warning(['Property ''' varargin{i_argin} ''' is not present in the Signal class or subclasses']);
                    end
                end
            end
            if ~subclassFlag
                self.History{end+1,1} = datestr(clock);
                self.History{end,2} = 'Calling Signal constructor';
                self = self.setDefaults;
                self.checkInstance;
            end
        end
        
        
        %% set, get and check methods
        
        % set data
        function self = set.Data(self, data)
            if ~isnumeric(data)
                error('Data property must be a numeric matrix');
            end
            self.Data = data;
        end
        
        % set default values
        function self = setDefaults(self)
            self = self.setDefaultChannelTags;
            self = self.setDefaultDimOrder;
        end
        
        % set default Data property
        function self = setDefaultData(self)
            if isempty(self.Data)
                s = size(self.Data);
                nChannels = s(end);
                self.ChannelTags = arrayfun(@(x) ['chan' num2str(x)],1:nChannels,'UniformOutput',0);
            end
        end
        
        % set default ChannelTags property
        function self = setDefaultChannelTags(self)
            if isempty(self.ChannelTags)
                s = size(self.Data);
                nChannels = s(end);
                self.ChannelTags = arrayfun(@(x) ['chan' num2str(x)],1:nChannels,'UniformOutput',0);
            end
        end
        
        % set default DimOrder property
        function self = setDefaultDimOrder(self)
            if isempty(self.DimOrder)
                nDims = ndims(self.Data);
                self.DimOrder(1:nDims-1) = arrayfun(@(x) ['dim' num2str(x)],1:nDims-1,'UniformOutput',0);
                self.DimOrder{nDims} = 'chan';
            end
        end
                
        % check instance properties
        function checkInstance(self)
%             self.checkData;
            self.checkChannelTags;
            self.checkDimOrder;
        end
                
        % check ChannelTags property
        function checkChannelTags(self)
            if size(self.ChannelTags,2) ~= size(self.Data, ndims(self.Data))
                error('the number of channels in ChannelTags property does not correspond to the last dimension in Data property');
            end
        end
        
        % check DimOrder property
        function checkDimOrder(self)
            if size(self.DimOrder,2) ~= ndims(self.Data)
                error('the number of dimensions in DimOrder property does not correspond to the number of dimensions in Data property');
            end
        end
        
        
        %% other methods
        
        % dim index
        function dimIndex = dimIndex(self, dimString)
            dimIndex = find(strcmpi(self.DimOrder, dimString));
            if isempty(dimIndex)
                error(['dimension ''' dimString ''' does not exist']);
            end
        end
        
        % clear hidden Temp property
        function self = clearTemp(self)
            self.Temp = [];
        end
        
        
        %% external methods
        
        zeroMeanSignal = meanRemoval(self,dim)
        
        % to do
        sortedSignal = sort(self, options)
        normalizedSignal = normalize(self, options)
        avgSignal = average(self, options)
        newSignal = concatenate(self, otherSignals, dim)
        
        
    end
end