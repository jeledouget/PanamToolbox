% Method for class 'Signal'
% Concatenate 'Signal' objects
% INPUTS
    % otherSignals : vector array or cell of Signals objects to concatenate to
    % self
    % dim : key to the dimension along which mean remval is performed (ex :
    % time), or number of the dimension
% OUTPUT
    % newSignal : 'Signal' object with concatenation of otherSignals



function newSignal = concatenate(self, otherSignals, dim, subclassFlag)

% default
if nargin < 4 || isempty(subclassFlag)
    subclassFlag = 0;
end
if nargin < 3 || isempty(dim)
    dim = 'chan';
end
if ~iscell(otherSignals)
    otherSignals= num2cell(otherSignals);
end

% check input
self.checkInstance;
cellfun(@checkInstance, otherSignals);
dimOrders = [{self.DimOrder}, cellfun(@(x) x.DimOrder, otherSignals, 'UniformOutput',0)];
if ~isequal(dimOrders{:})
    error('DimOrder properties differ for the structures to concatenate');
end

% handle dimensions
if ischar(dim)
    dimName = dim;
    dim = self.dimIndex(dim);
else
    dimName = self.DimOrder(dim);
end

% check input : consistency of dimensions
allDimensions = [size(self.Data), cellfun(@(x) size(x.Data), otherSignals, 'UniformOutput',0)];
allDimensions = cellfun(@(x) setdiff(x, x(dim)), allDimensions, 'UniformOutput', 0);
if ~isequal(allDimensions{:})
    error('the dimensions for concatenation do not match ; did you correctly specify the concatenation dimension ?');
end

% copy of the object
newSignal = self;

% concatenation
tmp = cellfun(@(x) x.Data, otherSignals, 'UniformOutput', 0);
newSignal.Data = cat(dim, self.Data, tmp{:});
if strcmpi(dimName, 'chan')
    tmp = cellfun(@(x) x.ChannelTags, otherSignals, 'UniformOutput', 0);
    newSignal.ChannelTags = cat(2, self.ChannelTags, tmp{:});
    if(length(unique(newSignal.ChannelTags)) < length(newSignal.ChannelTags))
        warning('WARNING : non-unicity in the names of channels in the created Signal object');
    end
else % channels must be the same
    tmp = cellfun(@(x) x.ChannelTags, otherSignals, 'UniformOutput', 0);
    channels = [{self.ChannelTags}, tmp];
    if ~isequal(channels{:})
        error('channels must be the same for concatenation');
    end
end

% warning
warning('Infos property not modified by concatenate method for Signal object');

% history
if ~subclassFlag
    newSignal.History{end+1,1} = datestr(clock);
    newSignal.History{end,2} = ...
        'Concatenation of Signals';
end

end