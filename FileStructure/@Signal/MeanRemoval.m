% Method for class 'Signal'
% Mean removal of a 'Signal' object
% INPUTS
    % dim : key to the dimension along which mean remval is performed (ex :
    % time)
% OUTPUT
    % zeroMeanSignal : 'Signal' object with removed mean



function zeroMeanSignal = MeanRemoval(self,dim)

% copy of the object
zeroMeanSignal = self;

% mean removal
dimIndex = self.DimIndex(dim);
reps = ones(1,length(self.DimOrder));
reps(dimIndex) = size(self.Data,dimIndex);
zeroMeanSignal.Data = self.Data - repmat(nanmean(self.Data,dimIndex),reps);

% history
zeroMeanSignal.History{end+1,1} = datestr(clock);
zeroMeanSignal.History{end,2} = ...
        ['Mean Removal of the signalof dim' dim];

end