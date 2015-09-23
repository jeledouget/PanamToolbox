% Method for class 'TimeFreqSignal' and subclasses
%  avgElements : average the elements of a TimeFreqSignal object
% elements must have the same dimensions
% INPUTS
    % 
% OUTPUT
    % avgSignal : between-elements TimeFreqSignal average



function avgSignal = avgElements(self, varargin)

% check Time
if ~ (all(arrayfun(@isNumTime, self)) || ~any(arrayfun(@isNumTime, self)))
    error('Time property of the elements of the TimeSignal must be all numeric or all discrete');
end

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
defaultOption.timeAxis = 'min'; % by default : timeaxis will be extended for all averaged elements (fill with nans if necessary)
defaultOption.dt = 'min'; % space between time points is set at the minimum
defaultOption.events = 'keepRange'; % saves the range of events across elements via field 'Duration'. Other options : 'avgAll' to average values and 'keepOnlyConstant'
defaultOption.subclassFlag = 0;
option = setstructfields(defaultOption, varargin);

% modifiy time axis if necessary
if numel(self) > 1 && all(arrayfun(@isNumTime, self))
    if ~isequal(self.Time) 
        self = self.adjustTime(option);
    end
elseif ~any(arrayfun(@isNumTime, self)) % discrete times
    if ~isequal(self.Time) 
        error('To average discrete time TimeFreqSignals, time tags must be similar for all elements');
    end
end

% average
avgSignal = self.avgElements@FreqSignal('subclassFlag',1);
avgSignal.Events = SignalEvents.empty;
% unify events
for ii =1:numel(self)
    self(ii).Events = self(ii).Events.unifyEvents(0);
end
% keep only events that are present in all Signals
listNames = arrayfun(@(x) {x.Events.EventName}, self,'UniformOutput',0);
allNames = unique([listNames{:}]);
bad = [];
for ii = 1:numel(allNames)
    name = allNames{ii};
    if ~all(cellfun(@(x) ismember(name, x), listNames)) % suppress this event
        bad(end+1) = ii;
    end
end
for b = bad
    for ii = 1:numel(self)
        self(ii).Events = self(ii).Events.deleteEvents(allNames{b});
    end
end
% keep an event only if it is present the same number of times in all
% elements
allNames = {self(1).Events.EventName};
bad = [];
for ii = 1:numel(allNames)
    name = allNames{ii};
    n = arrayfun(@(x) numel(x.Events(strcmpi({x.Events.EventName},name)).Time), self);
    if length(unique(n)) > 1
        bad(end+1) = ii;
    end
end
for b = bad
    for ii = 1:numel(self)
        self(ii).Events = self(ii).Events.deleteEvents(allNames{b});
    end
end
% average events
allNames = {self(1).Events.EventName};
switch option.events
    case 'keepRange'
        for ii = 1:numel(allNames)
            name = allNames{ii};
            times = arrayfun(@(x) x.Events(strcmpi({x.Events.EventName},name)).Time, self, 'UniformOutput',0);
            times = cell2mat(times);
            times = times(:);
            avgT = min(times,[],1);
            duration = max(times,[],1) - min(times,[],1);
            avgSignal.Events(end+1) = SignalEvents(name, avgT, duration);
        end
    case 'avgAll'
        for ii = 1:numel(allNames)
            name = allNames{ii};
            times = arrayfun(@(x) x.Events(strcmpi({x.Events.EventName},name)).Time, self, 'UniformOutput',0);
            times = cell2mat(times');
            avgT = mean(times,1);
            avgSignal.Events(end+1) = SignalEvents(name, avgT);
        end
    case 'keepOnlyConstant'
        for ii = 1:numel(allNames)
            name = allNames{ii};
            times = arrayfun(@(x) x.Events(strcmpi({x.Events.EventName},name)).Time, self, 'UniformOutput',0);
            times = cell2mat(times');
            if all(arrayfun(@(i) length(unique(times(:,i))) == 1, 1:size(times,2)))
                avgSignal.Events(end+1) = SignalEvents(name, mean(times,1));
            end
        end
end
% history
avgSignal.History{end+1,1} = datestr(clock);
avgSignal.History{end,2} = ...
        'Average the elements of the TimeFreqSignal object';

end
