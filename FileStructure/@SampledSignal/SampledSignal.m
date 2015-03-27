classdef SampledSignal < TimeSignal
    
    % SAMPLEDSIGNAL Class for time-sampled signal objects with regular time space
    %
    % Properties:
    % Fs = sampling frequency (usually Hz)

    
    %% properties
    properties
        Fs; % sampling frequency
    end
    
    %% methods
    
    methods
        
        % constructor
        function self = SampledSignal(data, fs, varargin)
            self@TimeSignal(data,varargin{:});
            self.Fs = fs;
            checkTime(self);
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
            
        % other methods
        lpFilteredSignal = LowPassFilter(self, cutoff, order)
        hpFilteredSignal = HighPassFilter(self, cutoff, order)
        notchedSignal = NotchFilter(self, width, order)
        bpFilteredSignal = BandPassFilter(self, cutoffLow, cutoffHigh, order)
        TKEOSignal = TKEO(self)
        resampledSignal = Resampling(self, newFreq)
        RmsSignal = RMS_Signal(self, timeWindow)

        
    end
end