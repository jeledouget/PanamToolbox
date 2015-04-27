% SUBPLOTS
% plot the 'TimeSignal' as data vs. time bins, one subplot per channel
% valid only if number of dimensions <= 2 in Data property


function h = subplots(self, commonOptions, specificOptions)


% TODO : check inputs


% default
if nargin < 3 || isempty(specificOptions)
    specificOptions = {};
end
if nargin < 2 || isempty(commonOptions)
    commonOptions = {};
end

% number of channels
nChannels = length(self.ChannelTags);

% colormap
cm = find(strcmpi(commonOptions,'colormap'));
if ~isempty(cm)
    cmap = commonOptions{cm+1};
    eval(['cmap = ' cmap '(nChannels);']);
    cmap = mat2cell(cmap, ones(1,nChannels),3);
    specificOptions{end+1} = 'color';
    specificOptions{end+1} = cmap;
    commonOptions(cm:cm+1) = [];
end


% plot
figure;
[horDim, vertDim] = panam_subplotDimensions(nChannels);
for ii = 1:nChannels
    specificOptions_current = specificOptions;
    for jj = 2:2:length(specificOptions)
        specificOptions_current{jj} = specificOptions{jj}{ii};
    end
    options = [commonOptions, specificOptions_current];
    h(ii) = subplot(horDim, vertDim, ii);
    if self.isNumTime % Time property is a nueric vector
        plot(self.Time, self.Data(:,ii), options{:});
    else
        plot(self.Data(:,ii), options{:});
        set(gca,'XTick',1:length(self.Time), 'XTickLabel', self.Time);
        a = axis;
        axis([a(1)-1 a(2)+1 a(3) a(4)]);
    end
    xlabel('Time')
    legend(h(ii), self.ChannelTags{ii})
    legend hide
end


end

