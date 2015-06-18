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

for ii = 1:numel(self)
    
    % handle input : channels
    if ischar(channels)
        channels = {channels};
    end
    if iscell(channels) &&  all(cellfun(@ischar, channels))
        channels = cell2mat(cellfun(@(x) find(strcmpi(x, self(ii).ChannelTags)), channels, 'UniformOutput', 0));
    end
    if ~isnumeric(channels) || ~isvector(channels)
        error('at this point, channels should be a numeric vector');
    end
    
    % order channels
    channels = sort(channels);
    
    % delete channels
    tmp =  self(ii).Data;
    nDims = ndims(self(ii).Data);
    dims = size(self(ii).Data);
    tmp = permute(tmp, [nDims, 2:nDims-1, 1]);
    tmp(channels,:) = [];
    tmp = reshape(tmp, [dims(nDims)-length(channels), dims(2:nDims-1), dims(1)]);
    tmp = permute(tmp, [nDims, 2:nDims-1, 1]);
    newSignal(ii).Data = tmp;
    newSignal(ii).ChannelTags(channels) = [];
    
    % history
    newSignal(ii).History{end+1,1} = datestr(clock);
    newSignal(ii).History{end,2} = ...
        ['Delete channels ' sprintf('%s ', self(ii).ChannelTags{channels})];
end

end

