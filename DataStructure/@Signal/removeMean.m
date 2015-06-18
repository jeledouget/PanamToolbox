% Method for class 'Signal'
% Mean removal of a 'Signal' object
% INPUTS
% dim : key to the dimension along which mean remval is performed (ex :
% time)
% OUTPUT
% zeroMeanSignal : 'Signal' object with removed mean



function zeroMeanSignal = removeMean(self,dim)

% copy of the object
zeroMeanSignal = self;

for ii = 1:numel(self)
    
    % handle dimensions
    if ischar(dim)
        dim = self(ii).dimIndex(dim);
    end
    
    % mean removal
    reps = ones(1,length(self(ii).DimOrder));
    reps(dim) = size(self(ii).Data,dim);
    zeroMeanSignal(ii).Data = self(ii).Data - repmat(nanmean(self(ii).Data,dim),reps);
    
    % history
    zeroMeanSignal(ii).History{end+1,1} = datestr(clock);
    zeroMeanSignal(ii).History{end,2} = ...
        ['Mean Removal of the signal, for dim ''' self(ii).DimOrder(dim) ''''];
end

end