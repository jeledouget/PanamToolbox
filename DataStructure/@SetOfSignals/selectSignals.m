% Method for class 'SetOfSignals'
% Keep selected Signals from Signals property, possibly place them in
% hidden Temp property
% INPUTS
    % selectedSignals : indices of the Signals to remove Signals
    % property
    % keepInTemp : flag (logical or double 0 or 1) - to keep or not the
    % removed Signals in Temp property
% OUTPUT
    % newSet : 'SetOfSignals' object with removed Signals



function newSet = selectSignals(self, selectedSignals, keepInTemp)

% copy of the object
newSet = self;


% remove selected Signals
newSet.Signals = newSet.Signals(selectedSignals);

% history
newSet.History{end+1,1} = datestr(clock);
newSet.History{end,2} = ...
        ['Select signals ' selectedSignals];

end