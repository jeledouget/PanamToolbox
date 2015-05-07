% Method for class 'FreqMarkers' and subclasses
%  unifyMarkers : acts on a vector FreqMarkers object : make all the
%  MarkerName unique by appending Freq when MarkerName match.
%  Also makes freq unique for each MarkerName
% INPUTS
% OUTPUT
    % newMarkers : modified FreqMarkers vector with unique MarkerName and
    % unique Freq for each element


function newMarkers = unifyMarkers(self)

% append time to common type of events
indToKeep = [];
for name = unique(lower({self.MarkerName}))
    indEvent = find(arrayfun(@(x) strcmpi(x.MarkerName, name{1}), self));
    for ii = indEvent(2:end)
        self(indEvent(1)).Freq = [self(indEvent(1)).Freq self(ii).Freq];
    end
    indToKeep(end+1) = indEvent(1);
end
        
% keep unique events    
newMarkers = self(sort(indToKeep));

% keep unique times in events
for ii = 1:length(newMarkers)
    newMarkers(ii).Freq = unique(newMarkers(ii).Freq, 'first');
end

end
