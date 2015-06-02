% Method for class 'SetOfSignals' and subclasses
%  sort : sort the Signals property of a SetOfSignals object
% INPUTS
% filter : defines how to sort the Signals. Can be a permutation
% vector, or a function, or a key of Infos property to sort by their
% values
% OUTPUT
% sortedSet : sorted SetOfSignals object


function sortedSet = sort(self, filter)

sortedSet = self;
sortedSet.Signals = self.Signals.sortElements(filter);

% history
sortedSet.History{end+1,1} = datestr(clock);
sortedSet.History{end,2} = ...
    'Sort the elements of the Signals property';

end