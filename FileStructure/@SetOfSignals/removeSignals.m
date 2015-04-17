% Method for class 'SetOfSignals'
% Remove selected Signals from Signals property, possibly place them in
% hidden Temp property
% INPUTS
    % selectedSignals : indices of the Signals to be put back in Signals
    % property
    % keepInTemp : flag (logical or double 0 or 1) - to keep or not the
    % removed Signals in Temp property
% OUTPUT
    % newSet : 'SetOfSignals' object with removed Signals



function newSet = removeSignals(self, selectedSignals, keepInTemp)

% copy of the object
newSet = self;

% history
newSet.History{end+1,1} = datestr(clock);
newSet.History{end,2} = ...
        ['Retrieval of signals ' selectedSignals];

end