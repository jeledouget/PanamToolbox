classdef TimeSignal < Signal
    
    %TIMESIGNAL Class for time-sampled signal objects
    % A signal has a Data and Time component
    %
    % 

    
    %% properties
    properties
        Event@SignalEvents;
    end
    
    %% methods
    
    methods
        
        % constructor
        function self = TimeSignal(data, varargin)
            self@Signal(data,varargin);
        end
        
        % get time
        function time = Time(self, index)
            if nargin < 2 || isempty(index)
                time = self.Dimensions('time');
            else
                timeTmp = self.Dimensions('time');
                time = timeTmp(index);
            end
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