% CONCATENATE
% method to concatenate several SetOfSignals instances
% INPUTS
    % otherSets : vector cell of SetOfSignals to concatenate to self
    % dimension : dimension of the Signals property along which to
    % concatenate the otherSets
    % forceMode : allow or not concatenation when DimOrder property differ
% OUTPUTS
    % newSet : conactenation of self and otherSets (new SetOfTrials
    % instance)


function newSet = concatenate(self, otherSets, dimension, forceMode)

% default
if nargin < 4 || isempty(forceMode)
    forceMode = 0;
end
if nargin < 3 || isempty(dimension)
    dimension = ndims(self.Signals);
end
if isa(otherSets, 'SetOfSignals')
    otherSets = {otherSets};
end

% check input : number of dimensions
nDims = [ndims(self.Signals), cellfun(@(x) ndims(x.Signals), otherSets, 'UniformOutput',0)];
if ~isequal(nDims{:})
    error('sets to concatenate do not all have the same number of dimensions in their ''Signals'' property: impossible to concatenate');
end

% check input : consistency of dimensions
allDimensions = [size(self.Signals), cellfun(@(x) size(x.Signals), otherSets, 'UniformOutput',0)];
allDimensions = cellfun(@(x) setdiff(x, x(dimension)), allDimensions, 'UniformOutput', 0);
if ~isequal(allDimensions{:})
    error('the dimensions for concatenation do not match ; did you correctly specify the concatenation dimension ?');
end

% check input : DimOrder
dimOrders = [{self.DimOrder}, cellfun(@(x) x.DimOrder, otherSets, 'UniformOutput',0)];
if ~isequal(dimOrders{:})
    if forceMode
        warning('DimOrder properties differ for the structures to concatenate : concatenation might be meaningless'); %#ok<WNTAG>
    else
        error('DimOrder properties differ for the structures to concatenate : use forceMode to force concatenation');
    end
end

% concatenation
newSet = self;
signals = [{self.Signals}, cellfun(@(x) x.Signals, otherSets, 'UniformOutput', 0)];
newSet.Signals = cat(dimension, signals{:});

% warning : Infos is not updated
warning('concatenation does not change Infos and DimOrder properties');


end

