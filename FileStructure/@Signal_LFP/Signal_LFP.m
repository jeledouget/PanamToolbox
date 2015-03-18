classdef Signal_LFP < Signal
    
    %SIGNAL_LFP Class for LFP Signal
    
    %% methods
    methods
        % constructor
        function sLFP = Signal_LFP(data, fech, varargin)
            sLFP@Signal(data, fech, varargin)
        end
        
        % data preProcessing
        function preProcessedLFP = PreProcessingLFP(thisObj,band)
            temp = thisObj.MeanRemoval;
            if nargin < 2
                temp = temp.BandPassFilter(2,200,4);
            else
                temp = temp.BandPassFilter(band(1),band(2),4);
            end
            preProcessedLFP = temp.NotchFilter(2,4);
            preProcessedLFP.Description{end+1} = 'PreProcessed';
        end
    end
end
