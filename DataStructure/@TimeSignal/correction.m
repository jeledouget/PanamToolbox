% Method for class 'TimeSignal' and subclasses
%  correction : apply a correction to the data. For example zscore, db...
% Baseline can be specified through absolute Time or relative to an event
% or 2
% INPUTS
% OUTPUT



function newSignal = correction(self, corrType, varargin)

% copy of the object
newSignal = self;

% options
if ~isempty(varargin)
    if ischar(varargin{1})
        isEV = 1;
        ev1 = varargin{1};
        if ischar(varargin{2})
            ev2 = varargin{2};
            delay = varargin{3};
        else
            ev2 = varargin{1};
            delay = varargin{2};
        end
    else
        isEV = 0;
        time = varargin{1};
    end
else
    isEV = 0;
    time = 'all';
end



for i = 1:numel(newSignal)
    
    % baseline time
    % correction is applied between the baseline start to the next baseline
    % start (ex stimulus onset minus 3s to 3s before next stimulus onset)
    if ~isEV
       if isequal(time,'all')
           samples{1} = [1 numel(self(i).Time)];
       else
           if (time(1) < self(i).Time(1)) || (time(2) > self(i).Time(end))
               error('input time to compute correction are not present in the Time vector');
           end
           if time(2) < time(1)
               error('time for correction must be a 2-elements increasing vector');
           end
           samples{1} = [panam_closest(self(i).Time, time(1)) panam_closest(self(i).Time, time(2))];
       end
    else
        events = self(i).Events.unifyEvents;
        eventNames = {events.EventName};
        ind1 = strcmp(eventNames, ev1);
        ind2 = strcmp(eventNames, ev2);
        time1 = events(ind1).Time + delay(1);
        time2 = events(ind2).Time + delay(2);
        if numel(time1) ~= numel(time2) || any(time2 - time1 < 0)
            error('problem with the choice of events and/or delays');
        end
        for j = 1:numel(time1)
            samples{j}(1) = panam_closest(self(i).Time, time1(j));
            samples{j}(2) = panam_closest(self(i).Time, time2(j));
        end
    end
    
    % apply correction
    data = self(i).Data;
    sz = size(data);
    data = reshape(data, sz(1),[]);
    for j = 1:numel(samples)
        % indices
        if j==1
            tmpSample(1) = 1;
        else
            tmpSample(1) = samples{j}(1);
        end
        if j==numel(samples)
            tmpSample(2) = sz(1);
        else
            tmpSample(2) = samples{j}(2);
        end
        % compute
        switch lower(corrType)
            case 'zscore'
                m = repmat(nanmean(data(samples{j}(1):samples{j}(2),:),1),numel(tmpSample(1):tmpSample(2)),1);
                s = repmat(nanstd(data(samples{j}(1):samples{j}(2),:),0,1),numel(tmpSample(1):tmpSample(2)),1);
                data(tmpSample(1):tmpSample(2),:) = (data(tmpSample(1):tmpSample(2),:) - m) ./ s;
            case 'db'
                m = repmat(nanmean(data(samples{j}(1):samples{j}(2),:),1),numel(tmpSample(1):tmpSample(2)),1);
                data(tmpSample(1):tmpSample(2),:) = 10*log10(data(tmpSample(1):tmpSample(2),:) ./ m);                
            case {'relativechange', 'relchange'}
                m = repmat(nanmean(data(samples{j}(1):samples{j}(2),:),1),numel(tmpSample(1):tmpSample(2)),1);
                data(tmpSample(1):tmpSample(2),:) = 100*(data(tmpSample(1):tmpSample(2),:) - m) ./ m;
            case 'difference'
                m = repmat(nanmean(data(samples{j}(1):samples{j}(2),:),1),numel(tmpSample(1):tmpSample(2)),1);
                data(tmpSample(1):tmpSample(2),:) = data(tmpSample(1):tmpSample(2),:) - m;
        end
    end
    newSignal(i).Data = reshape(data, sz);
end

% history
for ii = 1:numel(newSignal)
    newSignal(ii).History{end+1,1} = datestr(clock);
    newSignal(ii).History{end,2} = ...
        ['Correct the signal with ' corrType];
end
end
