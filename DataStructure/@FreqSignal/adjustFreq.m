% Method for class 'FreqSignal' and subclasses
%  adjustFreq : for muti-elements FreqSignal, make it that all elements
%  have the same Freq axis. Useful before averaging for example
% INPUTS
% OUTPUT



function adjustedSignal = adjustFreq(self, varargin)

% check that Freq property is numeric
if ~all(arrayfun(@isNumFreq, self))
    error('adjustFreq method only applies to FreqSignal objects with a numeric Freq property');
end

% copy of the object
adjustedSignal = self;
% args & options
if ~isempty(varargin)
    if ischar(varargin{1}) % kvPairs
        varargin = panam_args2struct(varargin);
    else % structure
        varargin = varargin{1};
    end
else
    varargin = [];
end
defaultOption.freqAxis = 'max'; % by default : freqaxis will be extended for all averaged elements (fill with nans if necessary)
defaultOption.df = 'min'; % space between time points is set at the minimum
defaultOption.interpOptions = {};
option = setstructfields(defaultOption, varargin);

% modifiy time axis if necessary
if numel(self) > 1 && ~isequal(self.Freq)
    minFreqs = arrayfun(@(x) min(x.Freq), self);
    maxFreqs = arrayfun(@(x) max(x.Freq), self);
    intervals = arrayfun(@(x) (max(x.Freq) - min(x.Freq)) / (length(x.Freq) - 1), self);
    switch option.df
        case 'min'
            interval = min(intervals);
        case 'max'
            interval = max(intevals);
        otherwise % user-defined window
            interval = option.df;
    end
    switch option.freqAxis
        case 'max'
            fMin = min(minFreqs);
            fMax = max(maxFreqs);
        case 'min'
            fMin = max(minFreqs);
            fMax = min(maxFreqs);
        otherwise % user-defined min and max freq
            fMin = option.freqAxis(1);
            fMax = option.freqAxis(2);
    end
    freqAxis = fMin:interval:fMax; % time axis on which the data is interpolated
else % all time axes are equal
    return;
end

% time-windowing
adjustedSignal = adjustedSignal.interpFreq(freqAxis, option.interpOptions{:});

% history
for ii = 1:numel(adjustedSignal)
    adjustedSignal(ii).History{end+1,1} = datestr(clock);
    adjustedSignal(ii).History{end,2} = ...
        ['Signal freq-adjusted from ' num2str(minFreq) 's to ' num2str(maxFreq) 's'];
end
end
