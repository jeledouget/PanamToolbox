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
preProcessedLFP = self.MeanRemoval;

% handle default band and compute bandpass, notch
if nargin < 2
    preProcessedLFP = preProcessedLFP.BandPassFilter(2,200,4);
else
    preProcessedLFP = preProcessedLFP.BandPassFilter(band(1),band(2),4);
end
preProcessedLFP = preProcessedLFP.NotchFilter(2,4);

% description
preProcessedLFP.Description = 'PreProcessed';

end

