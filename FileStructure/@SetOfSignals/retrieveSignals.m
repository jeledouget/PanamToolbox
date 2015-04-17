% Method for class 'SetOfSignals'
% Put selected Signals, stored in Temp property, back in Signals property
% WARNING : only works for vector 'Signals' property
% INPUTS
    % selectedSignals : indices of the Signals to be put back in Signals
    % property
% OUTPUT
    % newSet : 'SetOfSignals' object with added Signals



function newSet = retrieveSignals(self, selectedSignals)

% test the existence of the signals
if ~isfield(self.Temp, 'RemovedSignals') || isa(self.Temp.RemovedSignals, 'Signal') || ~isvector(self.Signals)
    error('method ''retrieveSignals'' only applicable for objects with vector ''Signals'' property and correponding Trials in Temp.RemovedSignals structure');
end
    

% copy of the object
newSet = self;

% retrieve the signals
for ii = 1:length(selectedSignals)
    try 
        self.Signals(end+1) = self.Temp.RemovedTrials(selectedSignals(ii));
    catch err
        disp(err.message);
        error('impossible to retrieve the selected Signals : method aborted');
    end
end
self.Temp.RemovedSignals(selectedSignals) = [];
if isempty(self.Temp.RemovedSignals)
    self.Temp = rmfield(self.Temp, 'RemovedSignals');
end

% history
newSet.History{end+1,1} = datestr(clock);
newSet.History{end,2} = ...
        'Retrieval of signals';

end