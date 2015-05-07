% Method for class 'SignalEvents' and subclasses
%  unifyEvents : acts on a vector SignalEvents object : make all the
%  EventName unique by appending Time and Duration when EventName match.
%  Also makes times unique for each EventName
% INPUTS
% OUTPUT
    % newEvents : modified SignalEvents vector with unique EventName and
    % unique Times for each element


function newEvents = unifyEvents(self)

% append time to common type of events
indToKeep = [];
for name = unique(lower({self.EventName}))
    indEvent = find(arrayfun(@(x) strcmpi(x.EventName, name{1}), self));
    for ii = indEvent(2:end)
        self(indEvent(1)).Time = [self(indEvent(1)).Time self(ii).Time];
        self(indEvent(1)).Duration = [self(indEvent(1)).Duration self(ii).Duration];
    end
    indToKeep(end+1) = indEvent(1);
end
        
% keep unique events    
newEvents = self(sort(indToKeep));

% keep unique times in events
for ii = 1:length(newEvents)
    [newEvents(ii).Time ind] = unique(newEvents(ii).Time, 'first');
    newEvents(ii).Duration = newEvents(ii).Duration(ind);
end

end
