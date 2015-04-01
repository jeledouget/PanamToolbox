classdef TimeFreqSignal < TimeSignal
    
    %TIMEFREQSIGNAL Class for time-frequency representations
    % 1st Dimension of Data property is for time
    % 2nd Dimension of Data property id for freq
    
    
    
    %% properties
    
    properties
        Freq; % numeric vector for frequency samples, or cell array (eg. {'alpha','beta'})
    end
    
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = TimeFreqSignal(data, varargin)
            subclassFlag = 0; % default : not called from  a subclass constructor
            indicesVarargin = []; % initiate vector for superclass constructor
            freq = 1:size(data,1); % default value for freq
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'freq'
                            freq = varargin{i_argin + 1};
                        case 'subclassflag'
                            subclassFlag = varargin{i_argin + 1};
                        otherwise
                            indicesVarargin = [indicesVarargin i_argin i_argin+1];
                    end
                end
            end
            self@TimeSignal(data,varargin{indicesVarargin},'subclassFlag',1);
            self.Freq = freq;
            if ~subclassFlag % only if the constructor is not called from a subclass
                self.History{end+1,1} = datestr(clock);
                self.History{end,2} = 'Calling TimeFreqSignal constructor';
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
        
        % check instance
        function checkDimensions(self)
            if ~strcmpi(self.DimOrder{1},'time')
                error('1st dimension of data property must represent time');
            end
        end
        
        
        %% other methods
        
        
        %% external methods
        
        
    end
end