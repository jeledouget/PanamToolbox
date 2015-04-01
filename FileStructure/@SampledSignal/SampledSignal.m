classdef SampledSignal < TimeSignal
    
    % SAMPLEDSIGNAL Class for time-sampled signal objects with regular time space
    % 1st Dimension of Data property is for time
    %
    % Properties:
    % Fs = sampling frequency (usually Hz)
    
    
    
    %% properties
    
    properties
        Fs; % sampling frequency
    end
    
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = SampledSignal(data, varargin)
            subclassFlag = 0;
            indicesVarargin = []; % initiate vector for superclass constructor
            fs = 1; % default value for Fs property
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'fs'
                            fs = varargin{i_argin + 1};
                        case 'subclassflag'
                            subclassFlag = varargin{i_argin + 1};
                        otherwise
                            indicesVarargin = [indicesVarargin i_argin i_argin+1];
                    end
                end
            end
            self@TimeSignal(data, varargin{indicesVarargin}, 'subclassflag', 1);
            self.Fs = fs;
            if ~subclassFlag
                self.History{end+1,1} = datestr(clock);
                self.History{end,2} = 'Calling SampledSignal constructor';
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
        
        % set methods
        function self = set.Fs(self, fs)
            if ~isscalar(fs) || ~isnumeric(fs)
                error('Fs property must be a numeric scalar');
            end
            self.Fs = fs;
        end
        
        % check time
        function checkTime(self)
            
        end
        
        
        %% other methods
        
        
        %% external methods
        
        lpFilteredSignal = LowPassFilter(self, cutoff, order)
        hpFilteredSignal = HighPassFilter(self, cutoff, order)
        notchedSignal = NotchFilter(self, width, order)
        bpFilteredSignal = BandPassFilter(self, cutoffLow, cutoffHigh, order)
        TKEOSignal = TKEO(self)
        resampledSignal = Resampling(self, newFreq)
        RmsSignal = RMS_Signal(self, timeWindow)
        
        
    end
end