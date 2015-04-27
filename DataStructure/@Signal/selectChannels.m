% Method for class 'Signal'
% deleteChannels : keep only selected channels in current 'Signal' object
% INPUTS
    % channels : chosen channels. Can be numerical (channel indices) or cell of
    % channel names as written in ChannelTags property
% OUTPUT
    % newSignal : 'Signal' object with only selected channels


function newSignal = selectChannels(self, channels)

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
channels= sort(channels);

% delete channels
tmp =  self.Data;
nDims = ndims(self.Data);
dims = size(self.Data);
tmp = permute(tmp, [nDims, 2:nDims-1, 1]);
tmp = tmp(channels,:);
tmp = reshape(tmp, [length(channels), dims(2:nDims-1), dims(1)]);
tmp = permute(tmp, [nDims, 2:nDims-1, 1]);
newSignal.Data = tmp;
newSignal.ChannelTags = newSignal.ChannelTags(channels);



end

