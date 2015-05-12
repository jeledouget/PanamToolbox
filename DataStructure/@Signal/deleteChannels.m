% Method for class 'Signal'
% deleteChannels : delete selected channels from current 'Signal' object
% INPUTS
    % channels : chosen channels. Can be numerical (channel indices) or cell of
    % channel names as written in ChannelTags property
% OUTPUT
    % newSignal : 'Signal' object without selected channels


function newSignal = deleteChannels(self, channels)

% copy of the object
newSignal = self;

% handle input : channels
if ischar(channels)
    channels = {channels};
end
if iscell(channels) &&  all(cellfun(@ischar, channels))
    channels = cell2mat(cellfun(@(x) find(strcmpi(x, self.ChannelTags)), channels, 'UniformOutput', 0));
end
if ~isnumeric(channels) || ~isvector(channels)
    error('at this point, channels soulb be a numeric vector');
end

% order channels
channels = sort(channels);

% delete channels
tmp =  self.Data;
nDims = ndims(self.Data);
dims = size(self.Data);
tmp = permute(tmp, [nDims, 2:nDims-1, 1]);
tmp(channels,:) = [];
tmp = reshape(tmp, [dims(nDims)-length(channels), dims(2:nDims-1), dims(1)]);
tmp = permute(tmp, [nDims, 2:nDims-1, 1]);
newSignal.Data = tmp;
newSignal.ChannelTags(channels) = [];

end

