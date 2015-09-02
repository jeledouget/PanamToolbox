% Method for class 'TimeSignal' and subclasses
%  adjustTime : for muti-elements TimeSignal, make it that all elements
%  have the same Time axis. Useful before averaging for example
% INPUTS
% OUTPUT



function adjustedSignal = adjustTime(self, varargin)

% check that Time property is numeric
if ~all(arrayfun(@isNumTime, self))
    error('adjustTime method only applies to TimeSignal objects with a numeric Time property');
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
defaultOption.timeAxis = 'max'; % by default : timeaxis will be extended for all averaged elements (fill with nans if necessary)
defaultOption.dt = 'min'; % space between time points is set at the minimum
defaultOption.interpOptions = {};
option = setstructfields(defaultOption, varargin);

% modifiy time axis if necessary
if numel(self) > 1 && ~isequal(self.Time)
    minTimes = arrayfun(@(x) min(x.Time), self);
    maxTimes = arrayfun(@(x) max(x.Time), self);
    intervals = arrayfun(@(x) (max(x.Time) - min(x.Time)) / (length(x.Time) - 1), self);
    switch option.dt
        case 'min'
            interval = min(intervals);
        case 'max'
            interval = max(intevals);
        otherwise % user-defined window
            interval = option.dt;
    end
    switch option.timeAxis
        case 'max'
            tMin = min(minTimes);
            tMax = max(maxTimes);
        case 'min'
            tMin = max(minTimes);
            tMax = min(maxTimes);
        otherwise % user-defined min and max time
            tMin = option.timeAxis(1);
            tMax = option.timeAxis(2);
    end
    timeAxis = tMin:interval:tMax; % time axis on which the data is interpolated
else % all time axes are equal
    return;
end

% time-windowing
adjustedSignal = adjustedSignal.interpTime(timeAxis, option.interpOptions{:});


% history
for ii = 1:numel(adjustedSignal)
    adjustedSignal(ii).History{end+1,1} = datestr(clock);
    adjustedSignal(ii).History{end,2} = ...
        ['Signal time-adjusted from ' num2str(timeAxis(1)) 's to ' num2str(timeAxis(end)) 's, with interval ' num2str(interval)];
end
end
