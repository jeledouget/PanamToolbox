classdef Signal
    
    %SIGNAL Class for signal objects
    %
    %Properties :
    %Data = numeric matrix with values of the signal
    %DimOrder = cell of strings with dimensions of the signal values (eg. {'time','channels'})
    %Infos = information about the signal (1 x 1 containers.Map) : can include TrialName, TrialNumber, Units, etc.;
    %History = history of operations on the Signal instance (n x 2 string cells)
    
    
    
    %% properties
    
    properties
        Data; % numeric matrix with values of the signal; see set.Data
        ChannelTags@cell vector; % ids for last dimension of data (usually channels, eg. {'C01D','C12D'})
        DimOrder@cell vector; % cell of strings with dimensions of the signal values (eg. {'time','channels'})
        Infos@containers.Map = containers.Map; % information about the signal (1 x 1 containers.Map) : can include TrialName, TrialNumber, Units, etc.;
        History@cell matrix; % history of operations on the Signal instance (n x 2 string cells)
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
                self.setDefaults;
                self.checkInstance;
            end
        end
        
        
        %% set, get and check methods
        
        function self = set.Data(self, data)
            if ~isnumeric(data)
                error('Data property must be a numeric matrix');
            end
            self.Data = data;
        end
        
        % set default values
        function self = setDefaults(self)
            self.setDefaultData;
            self.setDefaultChannelTags;
            self.setDefaultDimOrder;
        end
        
        % check instance properties
        function checkInstance(self)
            self.checkData;
            self.checkChannelTags;
            self.checkDimOrder;
        end
        
        
        %% other methods
        
        % dim index
        function dimIndex = DimIndex(self, dimString)
            dimIndex = find(strcmpi(self.DimOrder, dimString));
            if isempty(dimIndex)
                error(['dimension ''' dimString ''' does not exist']);
            end
        end
        
        
        %% external methods
        
        zeroMeanSignal = MeanRemoval(self,dim)
        
        
    end
end