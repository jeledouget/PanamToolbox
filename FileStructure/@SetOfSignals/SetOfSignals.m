classdef SetOfSignals
    
    % SETOFTRIALS Class containing information about a set of trials
    % e.g. a set of trials can contain the LFP signals for one subject and
    % one condition
    %
    % Properties:
    % 
    
    %% properties
    
    properties
        Signals@Signal matrix;
        Infos@containers.Map = containers.Map;
        History@cell matrix;
        RemovedSignals@Signal matrix;
    end
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = SetOfSignals(varargin)
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'signals'
                            self.Signals = varargin{i_argin + 1};
                        case 'infos'
                            self.Infos = varargin{i_argin + 1};
                        case 'dimorder'
                            self.RemovedSignals = varargin{i_argin + 1};
                        otherwise
                            warning(['Property ''' varargin{i_argin} ''' is not present in the SetOfSignals class or subclasses']);
                    end
                end
            end
            self.History{end+1,1} = datestr(clock);
            self.History{end,2} = 'Calling SetOfSignals constructor';
        end
        
        
        %% set, get and check methods
        
        
        %% other methods
        
        
        %% external methods
        
        
    end
    
end

