% Method for class 'TimeSignal' and subclasses
%  avgElements : average the elements of a TimeSignal object
% elements must have the same dimensions
% INPUTS
    % 
% OUTPUT
    % avgSignal : between-elements TimeSignal average



function avgSignal = avgElements(self, subclassFlag)

% subclass
if nargin <2 || isempty(subclassFlag)
    subclassFlag = 0;
end

% check input
if ~(all(arrayfun(@isNumTime, self)) || ~any(arrayfun(@isNumTime, self)))
    error('Time property of the elements of the TimeSignal must be all numeric or all discrete');
end

% check that Time property is the same for each element of self
if numel(self) > 1 && ~isequal(self.Time)
    lengths = arrayfun(@(x) length(x.Time), self);
    if any(lengths(2:end) - lengths(1:end-1)) % lengths of Time differ among elements of self
        error('Time properties are not of the same length');
    elseif self(1).isNumTime
        averageTime = mean(reshape([self.Time],[],numel(self)),2);
        for ii = 1:numel(self)
            orderTime{ii} = arrayfun(@(x) panam_closest(averageTime, x), self(ii).Time);
        end
        if isequal(orderTime{:}, 1:lengths(1))
            warning('times are not exactly the same in all elements of the TimeSignal');
        else
            error('Time should be the same');
        end
    else % discrete Times
        averageTime = self(1).Time;
        warning('Times do not have the same tag. Check Time properties');
    end
elseif self(1).isNumTime
    averageTime = mean(reshape([self.Time],[],numel(self)),2);
end

% average
avgSignal = self.avgElements@Signal(1);
avgSignal.Time = averageTime;
ev = [self.Events];
if ~isempty(ev)
    ev = ev.unifyEvents(0).avgEvents;
    avgSignal.Events = ev;
end

% history
if ~subclassFlag
    avgSignal.History{end+1,1} = datestr(clock);
    avgSignal.History{end,2} = ...
        'Average the elements of the TimeSignal object';
end

end
