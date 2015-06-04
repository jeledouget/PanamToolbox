% Method for class 'TimeFreqSignal' and subclasses
%  timeSignal : timeSignal object created from 
% INPUTS
%
% OUTPUT



function timeSignal = toTime(self, freq, varargin)

% check
self.checkInstance;

% check input
if ~isnumeric(freq) || numel(freq) > 2
    error('freq parameter must be numeric with 2 elements (band) or one element');
end

% data
self = self.avgFreq(freq, varargin{:});%  varargin can be a TimeTag
freqInd = self.dimIndex('freq');
nDims = ndims(self.Data);
% delete extra dimension
self.Data = permute(self.Data, [1:freqInd-1 freqInd+1:nDims freqInd]); 
self.DimOrder(freqInd) = [];
self.Infos('freq') = self.Freq; % save time tag before removal of Time

% delete kvPairs for Events, Time and History
kvPairs = panam_struct2args(self);
[~,ind] = intersect(kvPairs(1:2:end), {'FreqMarkers','Freq','History'});
kvPairs([2*ind-1 2*ind]) = [];

% constructor
timeSignal = TimeSignal(kvPairs{:});

% history
timeSignal.History{end+1,1} = datestr(clock);
timeSignal.History{end,2} = ...
    'From TimeFreqSignal, select freq';

end
