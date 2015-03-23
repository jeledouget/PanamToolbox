classdef Signal_LFP < SampledSignal
    
    %SIGNAL_LFP Class for LFP Signal
    
    %% methods
    methods
        % constructor
        function sLFP = Signal_LFP(data, fech, varargin)
            sLFP@Signal(data, fech, varargin)
        end
        
        % other methods
       preProcessedLFP = PreProcessingLFP(thisObj,band)
       
    end
end
