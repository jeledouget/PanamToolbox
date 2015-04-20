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

% copy in Temp property if selected
if nargin > 2 && keepInTemp
    if isfield(newSet.Temp, 'RemovedSignals')
        newSet.Temp.RemovedSignals(end+1:end+length(selectedSignals)) = newSet.Signals(selectedSignals);
    else
        newSet.Temp.RemovedSignals = newSet.Signals(selectedSignals);
    end
end

% remove selected Signals
newSet.Signals(selectedSignals) = [];

% history
newSet.History{end+1,1} = datestr(clock);
newSet.History{end,2} = ...
        ['Remove signals ' selectedSignals];

end