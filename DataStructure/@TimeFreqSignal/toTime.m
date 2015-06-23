% Method for class 'TimeFreqSignal' and subclasses
%  timeSignal : timeSignal object created from
% INPUTS
%
% OUTPUT



function timeSignal = toTime(self, freq, varargin)

% check
arrayfun(@checkInstance, self);

% check input
if ~isnumeric(freq) || numel(freq) > 2
    error('freq parameter must be numeric with 2 elements (band) or one element');
end

% preallocate
timeSignal(numel(self)) = TimeSignal;
timeSignal = reshape(timeSignal, size(self));

for ii = 1:numel(self)
    % data
    self(ii) = self(ii).avgFreq(freq, varargin{:});%  varargin can be a TimeTag
    freqInd = self(ii).dimIndex('freq');
    nDims = ndims(self(ii).Data);
    % delete extra dimension
    self(ii).Data = permute(self(ii).Data, [1:freqInd-1 freqInd+1:nDims freqInd]);
    self(ii).DimOrder(freqInd) = [];
    self(ii).Infos.freq = self(ii).Freq; % save time tag before removal of Time
    
    % delete kvPairs for Events, Time and History
    kvPairs = panam_struct2args(self(ii));
    [~,ind] = intersect(kvPairs(1:2:end), {'FreqMarkers','Freq','History'});
    kvPairs([2*ind-1 2*ind]) = [];
    
    % constructor
    timeSignal(ii) = TimeSignal(kvPairs{:});
    
    % history
    timeSignal(ii).History{end+1,1} = datestr(clock);
    timeSignal(ii).History{end,2} = ...
        'From TimeFreqSignal, select freq';
end

end
