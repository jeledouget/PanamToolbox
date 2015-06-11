% Method for class 'FreqMarkers' and subclasses
%  asList : acts on a vector FreqMarkers object : recreate the vector
%  with Markers that have only one Freq
% INPUTS
% OUTPUT
% listedMarkers : listed FreqMarkers vector


function listedMarkers = asList(self)

ind = 0; % init

for ii = 1:length(self)
    for jj = 1:length(self(ii).Freq)
        listedMarkers(ind+1) = FreqMarkers(self(ii).MarkerName, ...
            self(ii).Freq(jj), ...
            self(ii).Infos);
        ind = ind+1;
    end
end

end

