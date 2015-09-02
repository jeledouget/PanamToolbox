% Method for class 'FreqMarkers' and subclasses
%  deleteMarkers : acts on a vector FreqMarkers object : delete selected
%  FreqMarkers
% INPUTS
% OUTPUT
% newMarkers :  FreqMarkers vector without deleted markers


function newMarkers = deleteMarkers(self, varargin)


newMarkers = self;

% empty self
if isempty(self)
    return;
end

if isnumeric(varargin{1}) % delete by index
    newMarkers(varargin{1}) = [];
else % cell of events to delete
    if ischar(varargin{1}) % list of characters
        varargin = {varargin};
    end
    newMarkers = newMarkers.unifyMarkers(0);
    ind = cell2mat(cellfun(@(x) find(strcmpi(x,{newMarkers.MarkerName})), varargin, 'UniformOutput', 0));
    newMarkers(ind) = [];
end
newMarkers = newMarkers.asList;

end

