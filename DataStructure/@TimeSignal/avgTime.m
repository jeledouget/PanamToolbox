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
    isEvents = 0;
    timeBands = varargin{2};
    if length(varargin) > 2
        timeTags = varargin{3};
        if ischar(timeTags)
            timeTags = {timeTags};
        end
    end
elseif strcmpi(varargin{1}, 'events')
    isIndices = 0;
    isEvents = 1;
    timeBands = varargin{2};
    if length(varargin) > 2
        timeTags = varargin{3};
        if ischar(timeTags)
            timeTags = {timeTags};
        end
    end
else
    isIndices = 0;
    isEvents = 0;
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
    error('avgTime method only applies to TimeSignal objects with a numeric Time property');
end

% timeBands check
if ~iscell(timeBands) || (isEvents && ~iscell(timeBands{1}))
    timeBands = {timeBands};
end
for ii = 1:length(timeBands)
    if isscalar(timeBands{ii}) % in case of one time extraction
        timeBands{ii} = [timeBands{ii} timeBands{ii}];
    end
end

% set default timeTags
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
    data = zeros(size(timeBands,2), prod(dims(2:end)));
    for ii = 1:size(timeBands,2)
        if isIndices
            minSample = timeBands{ii}(1);
            maxSample = timeBands{ii}(2);
            if self(jj).isNumTime
                valMinTime = self(jj).Time(minSample);
                valMaxTime = self(jj).Time(maxSample);
            end
            isOK = 1;
            isExtractUniqueTime = (timeBands{ii}(1) == timeBands{ii}(2));
        elseif isEvents
            ev1 = find(strcmpi({self(jj).Events.EventName}, timeBands{ii}{1}),1);
            ev2 = find(strcmpi({self(jj).Events.EventName}, timeBands{ii}{2}),1);
            % possibly add a delay (ex : 2s before en event to 1s after)
            if length(timeBands{ii}) > 2
                delay = timeBands{ii}{3}; % must be a 1 x 2 numeric vector
            else
                delay = [0 0];
            end
            if ~isempty(ev1) && ~isempty(ev2)
                minTime = self(jj).Events(ev1).Time;
                maxTime = self(jj).Events(ev2).Time;
                minTime = minTime + delay(1);
                maxTime = maxTime + delay(2);
                [minSample valMinTime] = panam_closest(self(jj).Time, minTime);
                [maxSample valMaxTime] = panam_closest(self(jj).Time, maxTime);
                isOK = 1;
            else
                minTime = nan;
                maxTime = nan;
                isOK = 0;
            end
            isExtractUniqueTime = strcmpi(timeBands{ii}{1}, timeBands{ii}{2});
        else
            minTime = timeBands{ii}(1);
            maxTime = timeBands{ii}(2);
            [minSample valMinTime] = panam_closest(self(jj).Time, minTime);
            [maxSample valMaxTime] = panam_closest(self(jj).Time, maxTime);
            isExtractUniqueTime = (timeBands{ii}(1) == timeBands{ii}(2));
            isOK = 1;
        end
        modifiedInput = 0;
        if ~isExtractUniqueTime && (maxTime < min(self(jj).Time) || minTime > max(self(jj).Time))
            warning(['input number ' num2str(ii) ' has time out of range ; closest time is selected']);
            modifiedInput = 1;
        end
        if isOK
            data(ii,:) = nanmean(self(jj).Data(minSample:maxSample,:),1);
        else
            data(ii,:) = nan;
        end
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
    data = reshape(data, [size(timeBands,2) dims(2:end)]);
    
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

