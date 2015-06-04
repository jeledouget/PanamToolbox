% Method for class 'Signal'
% avgChannels : average selected channels in current 'Signal' object
% INPUTS
    % channels : chosen channels. Can be numerical (channel indices) or cell of
    % channel names as written in ChannelTags property, or 'all' for all
    % channels
    % avgChannelName : name of the channel created
    % keepChannels : 1 is averagechannel is appended, 0 is averageChannel
    % replaces other channels
% OUTPUT
    % newSignal : 'Signal' object with averaged channels


function newSignal = avgChannel(self, channels, avgChannelName, keepChannels)

% copy of the object
newSignal = self;

% handle inputs
if nargin < 4 || isempty(keepChannels)
    keepChannels = 0;
end
if nargin < 3 || isempty(avgChannelName)
    avgChannelName = 'avgChannel';
end
if nargin < 2 || isempty(channels)
    channels = 'all';
end

% handle channels
if ischar(channels)
    if strcmpi(channels, 'all')
        channels = 1:length(self.ChannelTags);
    else
        channels = {channels};
    end
end
if iscell(channels) &&  all(cellfun(@ischar, channels))
    channels = cell2mat(cellfun(@(x) find(strcmpi(x, self.ChannelTags)), channels, 'UniformOutput', 0));
end
if ~isnumeric(channels) || ~isvector(channels)
    error('at this point, channels should be a numeric vector');
end

% average
self = self.selectChannels(channels);
avgData = mean(self.Data, self.dimIndex('chan'));
if keepChannels
    newSignal.Data = cat(self.dimIndex('chan'), self.Data, avgData);
    newSignal.ChannelTags = [self.ChannelTags, avgChannelName];
else
    newSignal.Data = avgData;
    newSignal.ChannelTags = {avgChannelName};
end

% history
newSignal.History{end+1,1} = datestr(clock);
newSignal.History{end,2} = ...
    ['Average channels ' sprintf('%s ', self.ChannelTags{channels})];

end

