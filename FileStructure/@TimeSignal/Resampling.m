% Method for class 'Signal'
% Resample a 'Signal' object to a specified sampling frequency
% INPUTS
    % newFreq : new sampling frequency
% OUTPUT
    % resampledSignal : resampled 'Signal' object



function resampledSignal = Resampling(self, newFreq)

% copy of the object
resampledSignal = self;

% get old Freq
oldFreq = self.Fech;

% compute resampling
resampledSignal.Data = transpose(resample(self.Data',newFreq, oldFreq));
resampledSignal.Time = self.Time(1)+ 1. / newFreq * (0:size(resampledSignal.Data,2)-1);
resampledSignal.Fech = newFreq;

% history
zeroMeanSignal.History{end+1,1} = datestr(clock);
zeroMeanSignal.History{end,2} = ...
        ['Resampling : from ' num2str(oldFreq) ' to ' nul2str(newFreq)];

end

