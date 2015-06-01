% Method for class 'FreqMarkers' and subclasses
%  avgMarkers : acts on a vector FreqMarkers object : average all the Markers Freq.
% INPUTS
% OUTPUT
    % newMarkers : averaged FreqMarkers 


function newMarkers = avgMarkers(self)

self = self.unifyMarkers(0); % unique markers but all times kept

for ii = 1:length(self)
    self(ii).Freq = mean(self(ii).Freq,2);
end

% affect output
newMarkers = self;

end
