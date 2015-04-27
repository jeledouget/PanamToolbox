% Method for class 'TimeSignal' and subclasses
%  avgTime : average Time property according to specified windows of time,
%  and affect a time tag to each averaged window
% INPUTS
    % timeBands : cell of 1x2 vectors with first time and last time for the
    % window of averaging
    % timeTags = cell of char with the time tags
% OUTPUT
    % avgSignal : time-averaged TimeSignal object, with non-numeric Time
    % property(cell of tags)



function avgSignal = avgTime(self, timeBands, timeTags)

% check input
self.checkInstance;

% check that Time property is numeric
if ~(self.isNumTime)
    error('timeWindow method only applies to TimeSignal objects with a numeric Time property');
end

% timeBands check
if ~iscell(timeBands)
    timeBands = {timeBands};
end

% timeTags check
if ~iscell(timeTags)
    timeTags = {timeTags};
end

% compute average data
dims = size(self.Data);
data = zeros(length(timeBands), prod(dims(2:end)));
for ii = 1:length(timeBands)
    minTime = timeBands{ii}(1);
    maxTime = timeBands{ii}(2);
    [minSample valMinTime] = panam_closest(self.Time, minTime);
    [maxSample valMaxTime] = panam_closest(self.Time, maxTime);
    data(ii,:) = nanmean(self.Data(minSample:maxSample,:),1);
end
data = reshape(data, [length(timeBands) dims(2:end)]);

% assign output
if isa(self, 'SampledTimeSignal')
    avgSignal = self.subclass2TimeSignal;
else
    avgSignal = self;
end
avgSignal.Data = data;
avgSignal.Time = timeTags;

% check
avgSignal.checkInstance;

end

