% Method for class 'SignalEvents' and subclasses
%  asList : acts on a vector SignalEvents object : recreate the vector
%  with Events that have only one Time
% INPUTS
% OUTPUT
% listedEvents : listed SignalEvents vector


function listedEvents = asList(self)

ind = 0; % init

for ii = 1:length(self)
    for jj = 1:length(self(ii).Time)
        listedEvents(ind+1) = SignalEvents(self(ii).EventName, ...
            self(ii).Time(jj), ...
            self(ii).Duration(jj), ...
            self(ii).Info);
        ind = ind+1;
    end
end

end

