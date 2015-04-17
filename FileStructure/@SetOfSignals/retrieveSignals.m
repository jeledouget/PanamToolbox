% Method for class 'SetOfSignals'
% Put selected Signals, stored in Temp property, back in Signals property
% INPUTS
    % selectedSignals : indices of the Signals to be put back in Signals
    % property
% OUTPUT
    % newSet : 'SetOfSignals' object with added Signals



function newSet = retrieveSignals(self, selectedSignals)

% test the existence of the signals


% copy of the object
newSet = self;

% history
newSet.History{end+1,1} = datestr(clock);
newSet.History{end,2} = ...
        ['Retrieval of signals ' selectedSignals];

end