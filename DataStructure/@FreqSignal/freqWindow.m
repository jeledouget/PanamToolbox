% Method for class 'FreqSignal' and subclasses
% freqWindow : restrain the freq course of the 'Signal' object to the
% frequencies between 'minFreq' and 'maxFreq'
% INPUTS
    % minFreq : freq to begin the trial
    % maxFreq : freq to end to trial
% OUTPUT
    % freqWindowedSignal :  freq-windowed 'FreqSignal' object

    
    
function freqWindowedSignal = freqWindow(self, minFreq, maxFreq)

% check that Freq property is numeric
if ~(self.isNumFreq)
    error('freqWindow method only applies to FreqSignal objects with a numeric Freq property');
end


% handle default params
if nargin < 2 || isempty(minFreq)
    minFreq = -Inf;
end
if nargin < 3 || isempty(maxFreq)
    maxFreq = +Inf;
end

% copy of the object
freqWindowedSignal = self;

% extract the time-window
minSample = panam_closest(self.Freq, minFreq);
maxSample = panam_closest(self.Freq, maxFreq);
freqWindowedSignal.Freq = freqWindowedSignal.Freq(1,minSample:maxSample);
dims = size(freqWindowedSignal.Data);
dims(self.dimIndex('freq')) = maxSample - minSample + 1;
switch self.dimIndex('freq')
    case 1 % freq is 1st dimension
        freqWindowedSignal.Data = reshape(freqWindowedSignal.Data(minSample:maxSample,:), dims);
    case 2 % freq is 2nd dimension
        freqWindowedSignal.Data = reshape(freqWindowedSignal.Data(:,minSample:maxSample,:), dims);
    otherwise
        error('To use Freq-windowing, frequencies must be 1st or 2nd dimension in Data property');
end

% history
freqWindowedSignal.History{end+1,1} = datestr(clock);
freqWindowedSignal.History{end,2} = ...
        ['Frequency-windowing the signal : from ' num2str(minFreq) 's to ' num2str(maxFreq) 's'];

end
