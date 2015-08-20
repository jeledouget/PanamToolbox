% Method for class 'FreqSignal' and subclasses
%  avgElements : average the elements of a FreqSignal object
% elements must have the same dimensions
% INPUTS
%
% OUTPUT
% avgSignal : between-elements FreqSignal average


function avgSignal = avgElements(self, varargin)

% check input
if ~(all(arrayfun(@isNumFreq, self)) || ~any(arrayfun(@isNumFreq, self)))
    error('Freq property of the elements of the FreqSignal must be all numeric or all discrete');
end

% args & options
if ~isempty(varargin)
    if ischar(varargin{1}) % kvPairs
        varargin = panam_args2struct(varargin{:});
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
if numel(self) > 1 && ~isequal(self.Freq)
    if self(1).isNumFreq
        minFreq = arrayfun(@(x) min(x.Freq), self);
        maxFreq = arrayfun(@(x) max(x.Freq), self);
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
                fMin = min(minFreq);
                fMax = max(maxFreq);
            case 'min'
                fMin = max(minFreq);
                fMax = min(maxFreq);
            otherwise % user-defined min and max time
                fMin = option.freqAxis(1);
                fMax = option.freqAxis(2);
        end
        averageFreq = fMin:interval:fMax; % time axis on which the data is interpolated
        self = self.apply(@interpFreq, averageFreq);
    else
       error('Freq do not have the same tag : elements cannot be averaged. Check Freq properties');
    end
elseif self(1).isNumFreq
    averageFreq = mean(reshape([self.Freq],[],numel(self)),2);
else % discrete times
    averageFreq = self(1).Freq;
end

% average
avgSignal = self.avgElements@Signal('subclassFlag',1);
avgSignal.Freq = averageFreq;
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
if ~subclassFlag
    avgSignal.History{end+1,1} = datestr(clock);
    avgSignal.History{end,2} = ...
        'Average the elements of the FreqSignal object';
end

end
