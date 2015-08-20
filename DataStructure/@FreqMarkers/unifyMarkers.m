% Method for class 'FreqMarkers' and subclasses
%  unifyMarkers : acts on a vector FreqMarkers object : make all the
%  MarkerName unique by appending Freq when MarkerName match.
%  Also can make freq unique for each MarkerName (default behaviour)
% INPUTS
% OUTPUT
    % newMarkers : modified FreqMarkers vector with unique MarkerName and
    % unique Freq for each element


function newMarkers = unifyMarkers(self, uniqueFreq)

% default
if nargin < 2  || isempty(uniqueFreq)
    uniqueFreq = 1;
end

% append time to common type of events
indToKeep = [];
for name = unique(lower({self.MarkerName}))
    indEvent = find(arrayfun(@(x) strcmpi(x.MarkerName, name{1}), self));
    for ii = indEvent(2:end)
        self(indEvent(1)).Freq = [self(indEvent(1)).Freq self(ii).Freq];
        self(indEvent(1)).Window = [self(indEvent(1)).Window self(ii).Window];
    end
    indToKeep(end+1) = indEvent(1);
end
        
% keep unique events    
newMarkers = self(sort(indToKeep));

% keep unique freqs in markers
if uniqueFreq
    for ii = 1:length(newMarkers)
        newMarkers(ii).Freq = unique(newMarkers(ii).Freq, 'first');
        newEvents(ii).Window = newEvents(ii).Window(ind);
    end
end

end
