% Method for class 'Signal'
% Mean removal of a 'Signal' object
% INPUTS
    % dim : key to the dimension along which mean remval is performed (ex :
    % time)
% OUTPUT
    % zeroMeanSignal : 'Signal' object with removed mean



function zeroMeanSignal = meanRemoval(self,dim)

% copy of the object
zeroMeanSignal = self;

% handle dimensions
if ischar(dim)
    dim = self.dimIndex(dim);
end

% mean removal
reps = ones(1,length(self.DimOrder));
reps(dim) = size(self.Data,dim);
zeroMeanSignal.Data = self.Data - repmat(nanmean(self.Data,dim),reps);

% history
zeroMeanSignal.History{end+1,1} = datestr(clock);
zeroMeanSignal.History{end,2} = ...
        ['Mean Removal of the signal, for dim ''' self.DimOrder(dim) ''''];

end