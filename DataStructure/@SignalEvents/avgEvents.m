% Method for class 'SignalEvents' and subclasses
%  avgEvents : acts on a vector SignalEvents object : average all the Markers Time.
% INPUTS
% OUTPUT
    % newMarkers : averaged FreqMarkers 


function newEvents = avgEvents(self)

self = self.unifyEvents(0); % unique markers but all times kept

for ii = 1:length(self)
    self(ii).Time = mean(self(ii).Time,2);
    self(ii).Duration = mean(self(ii).Duration,2);
end

% affect output
newEvents = self;

end
