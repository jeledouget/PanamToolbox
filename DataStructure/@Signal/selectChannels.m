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

for ii = 1:numel(self)
    channelsTmp = channels;
    % handle input : channels
    if ischar(channelsTmp)
        channelsTmp = {channelsTmp};
    end
    if iscell(channelsTmp) &&  all(cellfun(@ischar, channelsTmp))
        channelsTmp = cell2mat(cellfun(@(x) find(strcmpi(x, self(ii).ChannelTags)), channelsTmp, 'UniformOutput', 0));
    end
    if ~isnumeric(channelsTmp) || ~isvector(channelsTmp)
        error('at this point, channels should be a numeric vector');
    end
    
    % order channels
    channelsTmp = sort(channelsTmp);
    
    % delete channels
    tmp =  self(ii).Data;
    nDims = ndims(self(ii).Data);
    if nDims == 2
        tmp = tmp(:, channelsTmp);
    elseif nDims == 3
        tmp = tmp(:,:,channelsTmp);
    else
        dims = size(self(ii).Data);
        tmp = permute(tmp, [nDims, 2:nDims-1, 1]);
        tmp = tmp(channelsTmp,:);
        tmp = reshape(tmp, [length(channelsTmp), dims(2:nDims-1), dims(1)]);
        tmp = permute(tmp, [nDims, 2:nDims-1, 1]);
    end
    newSignal(ii).Data = tmp;
    newSignal(ii).ChannelTags = newSignal(ii).ChannelTags(channelsTmp);
    
    % history
    newSignal(ii).History{end+1,1} = datestr(clock);
    newSignal(ii).History{end,2} = ...
        ['Keep selected channels : ' sprintf('%s ', self(ii).ChannelTags{channelsTmp})];
end

end

