% Method for class 'FreqSignal' and subclasses
%  adjustFreq : for muti-elements FreqSignal, make it that all elements
%  have the same Freq axis. Useful before averaging for example
% INPUTS
% OUTPUT



function adjustedSignal = adjustFreq(self, varargin)

% check that Time property is numeric
if ~all(arrayfun(@isNumFreq, self))
    error('adjustFreq method only applies to FreqSignal objects with a numeric Freq property');
end

% copy of the object
adjustedSignal = self;

% check that it is not already adjusted, and compute times
minAll = arrayfun(@(x) x.Freq(1), self(:));
maxAll =  arrayfun(@(x) x.Freq(end), self(:));
if length(unique(minAll)) == 1 && length(unique(maxAll)) == 1
    warning('object is already freq-adjusted');
    return;
else
    minFreq = max(minAll);
    maxFreq = min(maxAll);
end

% freq-windowing
adjustedSignal = adjustedSignal.freqWindow(minFreq, maxFreq, 'inf');
if ~isequal(adjustedSignal.Freq)
    adjustedSignal = adjustedSignal.interpFreq(adjustedSignal(1).Freq);
end

% history
for ii = 1:numel(adjustedSignal)
    adjustedSignal(ii).History{end+1,1} = datestr(clock);
    adjustedSignal(ii).History{end,2} = ...
        ['Signal freq-adjusted from ' num2str(minFreq) 's to ' num2str(maxFreq) 's'];
end
end
