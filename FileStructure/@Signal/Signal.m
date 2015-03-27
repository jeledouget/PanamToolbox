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
        DimOrder@cell vector; % cell of strings with dimensions of the signal values (eg. {'time','channels'}) 
        Infos@containers.Map = containers.Map; % information about the signal (1 x 1 containers.Map) : can include TrialName, TrialNumber, Units, etc.;
        History@cell matrix; % history of operations on the Signal instance (n x 2 string cells)
    end
    
    
    %% methods
    
    methods
        
        % constructor
        function self = Signal(varargin)
            self.History{end+1,1} = datestr(clock);
            self.History{end,2} = 'Calling Signal constructor';
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'data'
                            self.Data = varargin{i_argin + 1};
                        case 'infos'
                            self.Infos = varargin{i_argin + 1};
                        case 'dimorder'
                            self.DimOrder = varargin{i_argin + 1};
                        otherwise
                            warning(['Property ''' varargin{i_argin} ''' is not part of the constructor for TimeSignal']);
                    end
                end
            end
        end
        
        % set methods
        function self = set.Data(self, data)
            if ~isnumeric(data)
                error('Data property must be a numeric matrix');
            end
            self.Data = data;
        end
        
        % dim index
        function dimIndex = DimIndex(self, dimString)
            dimIndex = find(strcmpi(self.DimOrder, dimString));
            if isempty(dimIndex)
                error(['dimension ''' dimString ''' does not exist']);
            end
        end
        
        % other methods : choose dimension
        zeroMeanSignal = MeanRemoval(self,dim)
            
    end
end