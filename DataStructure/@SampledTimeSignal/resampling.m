% Method for class 'SampledTimeSignal'
% Resample a 'SampledTimeSignal' object to a specified sampling frequency
% INPUTS
    % newFreq : new sampling frequency
% OUTPUT
    % resampledSignal : resampled 'Signal' object



function resampledSignal = resampling(self, newFreq)

% dimensions of data
dims = size(self.Data);

% copy of the object
resampledSignal = self;

% get old Freq
oldFreq = self.Fs;

% compute resampling
data = resample(self.Data,newFreq, oldFreq);
dims(1) = size(data,1);
resampledSignal.Data = reshape(data, dims);
resampledSignal.Time = self.Time(1)+ 1. / newFreq * (0:size(resampledSignal.Data,1)-1);
resampledSignal.Fs = newFreq;

% check
resampledSignal.checkTime;

% history
resampledSignal.History{end+1,1} = datestr(clock);
resampledSignal.History{end,2} = ...
        ['Resampling : from ' num2str(oldFreq) ' to ' num2str(newFreq)];

end

