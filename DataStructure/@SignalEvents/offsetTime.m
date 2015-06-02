% Method for class 'SignalEvents' and subclasses
%  offsetTime : acts on a vector SignalEvents object : offset all Time properties by a given time.
% INPUTS
% OUTPUT
% newEvents : offset SignalEvents vector


function [newEvents, time] = offsetTime(self, offset, varargin)

% get time offset
if isnumeric(offset) % time of offset directly input
    time = offset;
elseif strcmpi(offset, 'eventnum')
    if isempty(varargin)
        error('varargin must contain the index of the Event to get the offset time, and optionnally the index in the Time property');
    end
    evIndex = varargin{1};
    if length(varargin) > 1
        evIndex2 = varargin{2};
        if strcmpi(evIndex2, 'first')
            evIndex2 = 1;
        elseif strcmpi(evIndex2, 'last')
            evIndex2 = length(self(evIndex).Time);
        end
    else
        evIndex2 = 1;
    end
    time = self(evIndex).Time(evIndex2);
else
    temp = self.unifyMarkers(0);
    evIndex = find(strcmpi({temp.EventName}, offset));
    if evIndex
        if ~isempty(varargin)
            evIndex2 = varargin{1};
            if strcmpi(evIndex2, 'first')
                evIndex2 = 1;
            elseif strcmpi(evIndex2, 'last')
                evIndex2 = length(self(evIndex).Time);
            end
        else
            evIndex2 = 1;
        end
    else
        error('offset must be a numeric value or the anme of an event or ''eventnum'' string followed by the index of the Event in the vector');
    end
    time = temp(evIndex).Time(evIndex2);    
end

% offset the time
newEvents = self;
for ii = 1:length(newEvents)
    newEvents(ii).Time = self(ii).Time - time;
end

end
