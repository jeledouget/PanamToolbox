classdef Signal_LFP < SampledSignal
    
    %SIGNAL_LFP Class for LFP Signal
    
    %% methods
    methods
        % constructor
        function sLFP = Signal_LFP(data, fs, varargin)
            if nargin < 2 || isempty(fs)
                fs = nan;
            end
            sLFP@SampledSignal(data, fs, varargin{:})
        end
        
        % other methods
       preProcessedLFP = PreProcessingLFP(thisObj,band)
       
    end
end
