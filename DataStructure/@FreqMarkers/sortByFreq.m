% Method for class 'FreqMarkers' and subclasses
%  sortByFreq : acts on a vector FreqMarkers object : recreate the vector
%  with Markers that have only one Freq and so that FreqMarkers are sorted by
%  ascending time
% INPUTS
% OUTPUT
% sortedEvents : freq-sorted FreqMarkers vector 


function sortedMarkers = sortByFreq(self)

% make as list 
sortedMarkers = self.asList;

% get the order of ascending times
freqs = [sortedMarkers.Freq]; % each event has unique Freq
[~, ind] = sort(freqs);

% make permutation
sortedMarkers = sortedMarkers(ind);

end
