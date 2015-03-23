classdef SampledSignal < TimeSignal
    
    %SAMPLEDSIGNAL Class for time-sampled signal objects with regular time
    %space
    %
    % 

    
    %% properties
    properties
        Fs
    end
    
    %% methods
    
    methods
        
        % constructor
        function self = SampledSignal(data, fech, varargin)
            self@TimeSignal(data,varargin);
            self.Fech = fech;
        end
        
        % set methods
        function self = set.Fs(self, fs)
            if ~isscalar(fech) || ~isnumeric(fech)
                error('Fech property must be a numeric scalar');
            end
            self.Fs = fs;
        end
            
        % other methods
        lpFilteredSignal = LowPassFilter(self, cutoff, order)
        hpFilteredSignal = HighPassFilter(self, cutoff, order)
        notchedSignal = NotchFilter(self, width, order)
        bpFilteredSignal = BandPassFilter(self, cutoffLow, cutoffHigh, order)
        TKEOSignal = TKEO(self)
        resampledSignal = Resampling(self, newFreq)
        timeWindowedSignal = TimeWindow(thisObj, minTime, maxTime)
        RmsSignal = RMS_Signal(self, timeWindow)

        
    end
end