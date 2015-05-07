% Method for class 'FreqSignal' and subclasses
%  avgFreq : average Freq property according to specified windows of freq,
%  and affect a freq tag to each averaged window
% INPUTS
    % freqBands : cell of 1x2 vectors with first freq and last freq for the
    % window of averaging
    % freqTags = cell of char with the freq tags
% OUTPUT
    % avgSignal : freq-averaged FreqSignal object, with non-numeric Freq
    % property(cell of tags)



function avgSignal = avgFreq(self, freqBands, freqTags)

% check input
self.checkInstance;

% check that Freq property is numeric
if ~(self.isNumFreq)
    error('freqWindow method only applies to FreqSignal objects with a numeric Freq property');
end

% set default freqBands
if nargin < 2 || isempty(freqBands)
    freqBands = [self.Freq(1) self.Freq(end)];
end

% freqBands check
if ~iscell(freqBands)
    freqBands = {freqBands};
end

% set default freqTags        
if nargin < 3 || isempty(freqTags)
    freqTags = cellfun(@(x) ['avg' num2str(x(1)) '-' num2str(x(2)) 'Hz'],freqBands,'UniformOutput',0);
end


% freqTags check
if ~iscell(freqTags)
    freqTags = {freqTags};
end

% check length
if length(freqBands) ~= length(freqTags)
    error('freqTags and freqBands inputs should be the same length');
end

% compute average data
nDims = ndims(self.Data);
dims = size(self.Data);
dimFreq = self.dimIndex('freq');
data = zeros(length(freqBands), prod(dims([1:dimFreq-1 dimFreq+1:nDims])));
dataTmp = permute(self.Data, [dimFreq 1:dimFreq-1 dimFreq+1:nDims]);
for ii = 1:length(freqBands)
    minFreq = freqBands{ii}(1);
    maxFreq = freqBands{ii}(2);
    [minSample valMinFreq] = panam_closest(self.Freq, minFreq);
    [maxSample valMaxFreq] = panam_closest(self.Freq, maxFreq);
    data(ii,:) = nanmean(dataTmp(minSample:maxSample,:),1);
end
data = reshape(data, [length(freqBands) dims([1:dimFreq-1 dimFreq+1:nDims])]);
data = permute(data, [2:dimFreq 1 dimFreq+1:nDims]);

% assign output
avgSignal = self;
avgSignal.Data = data;
avgSignal.Freq = freqTags;

% check
avgSignal.checkInstance;

% history
avgSignal.History{end+1,1} = datestr(clock);
avgSignal.History{end,2} = ...
        'Average the FreqSignal over the Frequency dimension';

end
