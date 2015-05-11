% Method for class 'Signal'
% Normalization of a 'Signal' object
% INPUTS
    % dim : key to the dimension along which mean remval is performed (ex :
    % time) or number of the dimension
% OUTPUT
    % normalizedSignal : normalized 'Signal' object



function normalizedSignal = normalize(self, dims, values, operation)

% default
if nargin < 4 || isempty(operation)
    operation = 'divide';
end

% handle dimensions
if ischar(dims)
    dims = {dims};
end
if iscell(dims)
    dimNames = dims;
    dims = cellfun(@(x) self.dimIndex(x), dims);
else
    dimNames = arrayfun(@(x) self.DimOrder(x), dims);
end
    
% check values
expectedSize = arrayfun(@(x) size(self.Data, x), dims);
if isscalar(expectedSize)
    expectedSize = [expectedSize, 1]; % for one dimensional normalization
end
if isvector(values) % make sure values is a column in this case
    values = values(:);
end
if ~isequal(expectedSize, size(values))
    error(' dimension of values does not correspond to the Data restricted to the selected dimensions');
end

% reorder dimensions
% [dims, permOrder] = sort(dims);
% values = permute(values, permOrder);
% dimNames = dimNames(permOrder);

% copy of the object
normalizedSignal = self;

% normalization
otherDims = setdiff(1:ndims(self.Data), dims);
otherDimsSize = arrayfun(@(x) size(self.Data, x), otherDims);
reps = [ones(1,length(dims)), otherDimsSize];
repValues = repmat(values, reps);
[~, permOrder] = sort([dims otherDims]);
repValues = permute(repValues, permOrder);
switch operation
    case 'divide'
        normalizedSignal.Data = normalizedSignal.Data ./ repValues;
    case 'minus'
        normalizedSignal.Data = normalizedSignal.Data - repValues;
    case {'plus', 'add'}
        normalizedSignal.Data = normalizedSignal.Data + repValues;
    case {'times', 'multiply'}
        normalizedSignal.Data = normalizedSignal.Data .* repValues;
end

% history
normalizedSignal.History{end+1,1} = datestr(clock);
normalizedSignal.History{end,2} = ['Normalization of the Signal object, with operation '''  ... 
    operation ''', along dimensions : ' sprintf(' %s',dimNames{:})];

end