% Method for class 'Signal_LFP'
% PreProcessingLFP : pre-processing of 'Signal_LFP' object
% - Band pass filter 
% - Notch Filter
% INPUTS
    % band (optional) : 1x 2 vector with low and high cutoff frequencies for
    % bandpass filter. Default is [2 200]
% OUTPUT
    % preProcessedLFP : preProcessed instance of 'Signal_LFP'

    
    
function preProcessedLFP = preProcessingLFP(self,band)

% copy of the object
preProcessedLFP = self.meanRemoval;

% handle default band and compute bandpass, notch
if nargin < 2
    preProcessedLFP = preProcessedLFP.bandPassFilter(2,200,4);
else
    preProcessedLFP = preProcessedLFP.bandPassFilter(band(1),band(2),4);
end
preProcessedLFP = preProcessedLFP.notchFilter(2,4);


end

