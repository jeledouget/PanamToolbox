% Method for class 'FreqSignal' and subclasses
%  avgElements : average the elements of a FreqSignal object
% elements must have the same dimensions
% INPUTS
%
% OUTPUT
% avgSignal : between-elements FreqSignal average


function avgSignal = avgElements(self, varargin)

if numel(self) == 1
    avgSignal = self;
    return;
end

% check input
if ~(all(arrayfun(@isNumFreq, self)) || ~any(arrayfun(@isNumFreq, self)))
    error('Freq property of the elements of the FreqSignal must be all numeric or all discrete');
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
defaultOption.freqAxis = 'max'; % by default : freq axis will be extended for all averaged elements (fill with nans if necessary)
defaultOption.df = 'min'; % space between freq points is set at the minimum
defaultOption.freqMarkers = 'keepRange'; % saves the range of freq markers across elements via field 'window'. Other options : 'avgAll' to average values and 'keepOnlyConstant'
defaultOption.subclassFlag = 0;
option = setstructfields(defaultOption, varargin);

% modifiy freq axis if necessary
if numel(self) > 1 && all(arrayfun(@isNumFreq, self))
    if ~isequal(self.Freq) 
        self = self.adjustFreq(option);
    end
else % discrete times
    if ~isequal(self.Freq) 
        error('To average discrete freq FreqSignals, freq tags must be similar for all elements');
    end
end


% average
avgSignal = self.avgElements@Signal(option);
avgSignal.FreqMarkers = FreqMarkers.empty;

% unify markers
for ii =1:numel(self)
    self(ii).FreqMarkers = self(ii).FreqMarkers.unifyMarkers(0);
end
% keep only markers that are present in all Signals
listNames = arrayfun(@(x) {x.FreqMarkers.MarkerName}, self,'UniformOutput',0);
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
        self(ii).FreqMarkers = self(ii).FreqMarkers.deleteMarkers(allNames{b});
    end
end
% keep a marker only if it is present the same number of times in all
% elements
allNames = {self(1).FreqMarkers.MarkerName};
bad = [];
for ii = 1:numel(allNames)
    name = allNames{ii};
    n = arrayfun(@(x) numel(x.FreqMarkers(strcmpi({x.FreqMarkers.MarkerName},name)).Freq), self);
    if length(unique(n)) > 1
        bad(end+1) = ii;
    end
end
for b = bad
    for ii = 1:numel(self)
        self(ii).FreqMarkers = self(ii).FreqMarkers.deleteMarkers(allNames{b});
    end
end
% average markers
allNames = {self(1).FreqMarkers.MarkerName};
switch option.freqMarkers
    case 'keepRange'
        for ii = 1:numel(allNames)
            name = allNames{ii};
            freq = arrayfun(@(x) x.FreqMarkers(strcmpi({x.FreqMarkers.MarkerName},name)).Freq, self, 'UniformOutput',0);
            freq = cell2mat(freq');
            avgF = min(freq,1);
            window = max(freq,1) - min(freq,1);
            avgSignal.FreqMarkers(end+1) = FreqMarkers(name, avgF, window);
        end
    case 'avgAll'
        for ii = 1:numel(allNames)
            name = allNames{ii};
            freq = arrayfun(@(x) x.FreqMarkers(strcmpi({x.FreqMarkers.MarkerName},name)).Freq, self, 'UniformOutput',0);
            freq = cell2mat(freq');
            avgF = mean(freq,1);
            avgSignal.FreqMarkers(end+1) = FreqMarkers(name, avgF);
        end
    case 'keepOnlyConstant'
        for ii = 1:numel(allNames)
            name = allNames{ii};
            freq = arrayfun(@(x) x.Events(strcmpi({x.FreqMarkers.MarkerName},name)).Freq, self, 'UniformOutput',0);
            freq = cell2mat(freq');
            if all(arrayfun(@(i) length(unique(freq(:,i))) == 1, 1:size(freq,2)))
                avgSignal.FreqMarkers(end+1) = FreqMarkers(name, mean(freq,1));
            end
        end
end


% history
if ~option.subclassFlag
    avgSignal.History{end+1,1} = datestr(clock);
    avgSignal.History{end,2} = ...
        'Average the elements of the FreqSignal object';
end

end
