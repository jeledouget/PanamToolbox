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
arrayfun(@checkInstance, self);

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
if ~isIndices && ~all(arrayfun(@isNumTime, self(:)))
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

% init
if isa(self, 'SampledTimeSignal')
    avgSignal = self.toTimeSignal;
else
    avgSignal = self;
end

% compute
for jj = 1:numel(self)
    % compute average data
    dims = size(self(jj).Data);
    data = zeros(length(timeBands), prod(dims(2:end)));
    for ii = 1:length(timeBands)
        if isIndices
            minSample = timeBands{ii}(1);
            maxSample = timeBands{ii}(2);
            if self(jj).isNumTime
                valMinTime = self(jj).Time(minSample);
                valMaxTime = self(jj).Time(maxSample);
            end
        else
            minTime = timeBands{ii}(1);
            maxTime = timeBands{ii}(2);
            [minSample valMinTime] = panam_closest(self(jj).Time, minTime);
            [maxSample valMaxTime] = panam_closest(self(jj).Time, maxTime);
        end
        isExtractUniqueTime = (timeBands{ii}(1) == timeBands{ii}(2));
        modifiedInput = 0;
        if ~isExtractUniqueTime && (maxTime < min(self(jj).Time) || minTime > max(self(jj).Time))
            warning(['input number ' num2str(ii) ' has time out of range ; closest time is selected']);
            modifiedInput = 1;
        end
        data(ii,:) = nanmean(self(jj).Data(minSample:maxSample,:),1);
        if isDefTimeTags
            if self(jj).isNumTime
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
    avgSignal(jj).Data = data;
    avgSignal(jj).Time = timeTags;
    
    % history
    avgSignal(jj).History{end+1,1} = datestr(clock);
    avgSignal(jj).History{end,2} = ...
        'Average / Extraction on the time dimension';
end

% check
arrayfun(@checkInstance,avgSignal);

end

