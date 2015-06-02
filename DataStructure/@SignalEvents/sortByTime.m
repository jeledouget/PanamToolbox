% Method for class 'SignalEvents' and subclasses
%  sortByTime : acts on a vector SignalEvents object : recreate the vector
%  with Events that have only one Time and so that Events are sorted by
%  ascending time
% INPUTS
% OUTPUT
% sortedEvents : time-sorteedSignalEvents vector 


function sortedEvents = sortByTime(self)

% make as list 
sortedEvents = self.asList;

% get the order of ascending times
times = [sortedEvents.Time]; % each event has unique Time
[~, ind] = sort(times);

% make permutation
sortedEvents = sortedEvents(ind);

end
