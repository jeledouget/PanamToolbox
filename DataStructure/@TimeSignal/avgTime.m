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



function avgSignal = avgTime(self, varargin)

% check input
self.checkInstance;

% varargin
if strcmpi(varargin{1}, 'indices')
    isIndices = 1;
    timeBands = varargin{2};
    if length(varargin) > 2
        timeTags = varargin{3};
        if ischar(timeTags)
            timeTags = {timeTags};
        end
    end
else
    isIndices = 0;
    timeBands = varargin{1};
    if length(varargin) > 1
        timeTags = varargin{2};
        if ischar(timeTags)
            timeTags = {timeTags};
        end
    end
end


% check that Time property is numeric, except if average on indices
if ~isIndices && ~(self.isNumTime)
    error('timeWindow method only applies to TimeSignal objects with a numeric Time property');
end

% timeBands check
if ~iscell(timeBands)
    timeBands = {timeBands};
end
for ii = 1:length(timeBands)
    if isscalar(timeBands{ii}) % in case of one time extraction
        timeBands{ii} = [timeBands{ii} timeBands{ii}];
    end
end

% set default freqTags
isDefTimeTags = 1; % default
if exist('timeTags','var')
    isDefTimeTags = 0;
end

% compute average data
dims = size(self.Data);
data = zeros(length(timeBands), prod(dims(2:end)));
for ii = 1:length(timeBands)
    if isIndices
        minSample = timeBands{ii}(1);
        maxSample = timeBands{ii}(2);
        if self.isNumTime
            valMinTime = self.Time(minSample);
            valMaxTime = self.Time(maxSample);
        end
    else
        minTime = timeBands{ii}(1);
        maxTime = timeBands{ii}(2);
        [minSample valMinTime] = panam_closest(self.Time, minTime);
        [maxSample valMaxTime] = panam_closest(self.Time, maxTime);
    end
    isExtractUniqueTime = (timeBands{ii}(1) == timeBands{ii}(2));
    modifiedInput = 0;
    if ~isExtractUniqueTime && (maxTime < min(self.Time) || minTime > max(self.Time))
        warning(['input number ' num2str(ii) ' has time out of range ; closest time is selected']);
        modifiedInput = 1;
    end
    data(ii,:) = nanmean(self.Data(minSample:maxSample,:),1);
    if isDefTimeTags
        if self.isNumTime
            if isExtractUniqueTime
                timeTags{ii} = num2str(valMaxTime,2);
            else
                timeTags{ii} = ['avg:' num2str(valMinTime,2) '-' num2str(valMaxTime,2)];
            end
        else
            timeTags{ii} = ['avg' num2str(ii)];
        end
    end
    if modifiedInput
        timeTags{ii} = [timeTags{ii} ' - ModifiedFromInput'];
    end
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

% history
avgSignal.History{end+1,1} = datestr(clock);
avgSignal.History{end,2} = ...
    'Average / Extraction on the time dimension';

end

