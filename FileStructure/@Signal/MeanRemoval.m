% Method for class 'Signal'
% Mean removal of a 'Signal' object
% INPUTS   
% OUTPUT
    % zeroMeanSignal : 'Signal' object with removed mean



function zeroMeanSignal = MeanRemoval(self)

% copy of the object
zeroMeanSignal = self;

% mean removal
zeroMeanSignal.Data = self.Data - nanmean(self.Data,2)*ones(1,length(self.Data));

% history
zeroMeanSignal.History{end+1,1} = datestr(clock);
zeroMeanSignal.History{end,2} = ...
        'Mean Removal of the signal';

end