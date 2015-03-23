classdef Signal
    
    %SIGNAL Class for signal objects
    % A signal has a Data component and Dimensions information
    %
    %Data = data of the signal (numeric matrix)
    %Dimensions = dimensions of the Data property (containers.Map, ie 'time' key and Time vecotr for value);
    %Infos = description of the signal (1 x 1 containers.Map) : includes TrialName, TrialNumber, Units, etc.;
    %History = history of operations applied on the object (n x 2 string cells)
    
    %% properties
    properties
        Data; % see set method for requirements
        Dimensions@containers.Map; % 'time' time samples, 'freq' freq samples etc.
        DimOrder@cell vector;
        Infos@containers.Map;
        History@cell matrix;
    end
    
    %% methods
    
    methods
        
        % constructor
        function self = Signal(data, varargin)
            % varargin format : (...,'PropertyName', 'PropertyValue',...)
            self.Data = data;
            self.History{end+1,1} = datestr(clock);
            self.History{end,2} = 'Creation of the Signal structure';
            if nargin >= 2 && ~isempty(varargin{1})
                if mod(length(varargin{1}),2)==0
                    for i_argin = 1 : 2 : length(varargin{1})
                        switch lower(varargin{1}{i_argin})
                            case 'dimensions'
                                self.Dimensions = varargin{1}{i_argin + 1};
                            case 'dimorder'
                                self.DimOrder = varargin{1}{i_argin + 1};
                            case 'infos'
                                self.Infos = varargin{1}{i_argin + 1};
                            otherwise
                                error(['Propriete ' varargin{1}{i_argin} 'inexistante dans la classe'])
                        end
                    end
                else
                    error('Nombre impair d''arguments supplementaires')
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
        
        % other methods  
        zeroMeanSignal = MeanRemoval(self,dim)
        

        
    end
end