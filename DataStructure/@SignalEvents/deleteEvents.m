% Method for class 'SignalEvents' and subclasses
%  deleteEvents : acts on a vector SignalEvents object : delete selected
%  SignalEvents
% INPUTS
% OUTPUT
% newEvents :  SignalEvents vector without deleted events


function newEvents = deleteEvents(self, varargin)

newEvents = self;

% empty self
if isempty(self)
    return;
end

if isnumeric(varargin{1}) % delete by index
    newEvents(varargin{1}) = [];
else % cell of events to delete
    if iscell(varargin{1}) % list of events in a cell
        varargin = varargin{1};
    end
    newEvents = newEvents.unifyEvents(0);
    ind = cell2mat(cellfun(@(x) find(strcmpi(x,{newEvents.EventName})), varargin, 'UniformOutput', 0));
    newEvents(ind) = [];
end

newEvents = newEvents.sortByTime;

end

