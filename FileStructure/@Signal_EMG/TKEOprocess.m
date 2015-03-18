% TKEOprocess : TKEO processing of 'Signal_EMG'  object
% cf TKEO method for overloaded 'Signal' object
% INPUTS
% OUTPUT
    % newSignal : TKEO'd + Processed 'Signal_EMG' object


function newSignal = TKEOprocess(thisSignal)

% copy of the object and filters
% + compute TKEO
newSignal = thisSignal.BandPassFilter(10,499,6);
newSignal = newSignal.HighPassFilter(20, 6);
newSignal = newSignal.TKEO;
newSignal = newSignal.LowPassFilter(50, 6);
newSignal.TrialName = newSignal.TrialName;
newSignal.TrialNum = newSignal.TrialNum;
newSignal.Description = {'TKEO processing'};


end