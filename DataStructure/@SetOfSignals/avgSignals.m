% Method for class 'SetOfSignals' and subclasses
%  avgSignals : average the Signals property of a SetOfSignals object
% INPUTS
% 
% OUTPUT
% avgSet : averaged SetOfSignals object


function avgSet = avgSignals(self)

avgSet = self;
avgSet.Signals = self.Signals.avgElements;

% history
avgSet.History{end+1,1} = datestr(clock);
avgSet.History{end,2} = ...
    'Average the elements of the Signals property';

end