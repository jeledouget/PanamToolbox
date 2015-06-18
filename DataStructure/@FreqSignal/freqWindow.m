% Method for class 'FreqSignal' and subclasses
% freqWindow : restrain the freq course of the 'Signal' object to the
% frequencies between 'minFreq' and 'maxFreq'
% INPUTS
% minFreq : freq to begin the trial
% maxFreq : freq to end to trial
% OUTPUT
% freqWindowedSignal :  freq-windowed 'FreqSignal' object



function freqWindowedSignal = freqWindow(self, minFreq, maxFreq, mode)

% check that Freq property is numeric
if ~all(arrayfun(@isNumFreq, self))
    error('freqWindow method only applies to FreqSignal objects with a numeric Freq property');
end

% copy of the object
freqWindowedSignal = self;

% handle default params
if nargin < 2 || isempty(minFreq)
    minFreq = -Inf;
end
if nargin < 3 || isempty(maxFreq)
    maxFreq = +Inf;
end
if nargin < 4 || isempty(mode)
    mode = 'normal';
end
if ischar(mode)
    mode = {mode, mode};
end

for ii = 1:numel(self)
    % extract the time-window
    minSample = panam_closest(self(ii).Freq, minFreq, mode{1});
    maxSample = panam_closest(self(ii).Freq, maxFreq, mode{2});
    freqWindowedSignal(ii).Freq = freqWindowedSignal(ii).Freq(1,minSample:maxSample);
    dims = size(freqWindowedSignal(ii).Data);
    dims(self(ii).dimIndex('freq')) = maxSample - minSample + 1;
    switch self(ii).dimIndex('freq')
        case 1 % freq is 1st dimension
            freqWindowedSignal(ii).Data = reshape(freqWindowedSignal(ii).Data(minSample:maxSample,:), dims);
        case 2 % freq is 2nd dimension
            freqWindowedSignal(ii).Data = reshape(freqWindowedSignal(ii).Data(:,minSample:maxSample,:), dims);
        otherwise
            error('To use Freq-windowing, frequencies must be 1st or 2nd dimension in Data property');
    end
    
    % handle markers
    freqWindowedSignal(ii).FreqMarkers = freqWindowedSignal(ii).FreqMarkers.asList;
    indToRemove = arrayfun(@(x) (x.Freq > maxFreq || x.Freq < minFreq), freqWindowedSignal(ii).FreqMarkers);
    freqWindowedSignal(ii).FreqMarkers(indToRemove) = [];
    
    
    % history
    freqWindowedSignal(ii).History{end+1,1} = datestr(clock);
    freqWindowedSignal(ii).History{end,2} = ...
        ['Frequency-windowing the signal : from ' num2str(minFreq) 's to ' num2str(maxFreq) 's'];
end
end
