% Method for class 'TimeFreqSignal' and subclasses
%  freqSignal : FreqSignal object created from 
% INPUTS
%
% OUTPUT



function freqSignal = toFreq(self, time, varargin)

% check
self.checkInstance;

% check input
if ~isnumeric(time) || numel(time) > 2
    error('time parameter must be numeric with 2 elements (band) or one element');
end

% data
self = self.avgTime(time, varargin{:});%  varargin can be a TimeTag
timeInd = self.dimIndex('time');
nDims = ndims(self.Data);
% delete extra dimension
self.Data = permute(self.Data, [1:timeInd-1 timeInd+1:nDims timeInd]); 
self.DimOrder(timeInd) = [];
self.Infos('time') = self.Time; % save time tag before removal of Time

% delete kvPairs for Events, Time and History
kvPairs = panam_struct2args(self);
[~,ind] = intersect(kvPairs(1:2:end), {'Events','Time','History'});
kvPairs([2*ind-1 2*ind]) = [];

% constructor
freqSignal = FreqSignal(kvPairs{:});

% history
freqSignal.History{end+1,1} = datestr(clock);
freqSignal.History{end,2} = ...
    'From TimeFreqSignal, select time';

end
