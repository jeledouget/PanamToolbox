% Method for class 'TimeFreqSignal' and subclasses
%  freqSignal : FreqSignal object created from
% INPUTS
%
% OUTPUT



function freqSignal = toFreq(self, time, varargin)

% check
arrayfun(@checkInstance, self);

% check input
if ~isnumeric(time) || numel(time) > 2
    error('time parameter must be numeric with 2 elements (band) or one element');
end

% preallocate
freqSignal(numel(self)) = FreqSignal;
freqSignal = reshape(freqSignal, size(self));

for i = 1:numel(self)
    % data
    self(ii) = self(ii).avgTime(time, varargin{:});%  varargin can be a TimeTag
    timeInd = self(ii).dimIndex('time');
    nDims = ndims(self(ii).Data);
    % delete extra dimension
    self(ii).Data = permute(self(ii).Data, [1:timeInd-1 timeInd+1:nDims timeInd]);
    self(ii).DimOrder(timeInd) = [];
    self(ii).Infos('time') = self(ii).Time; % save time tag before removal of Time
    
    % delete kvPairs for Events, Time and History
    kvPairs = panam_struct2args(self(ii));
    [~,ind] = intersect(kvPairs(1:2:end), {'Events','Time','History'});
    kvPairs([2*ind-1 2*ind]) = [];
    
    % constructor
    freqSignal(ii) = FreqSignal(kvPairs{:});
    
    % history
    freqSignal(ii).History{end+1,1} = datestr(clock);
    freqSignal(ii).History{end,2} = ...
        'From TimeFreqSignal, select time';
end

end
