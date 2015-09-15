% COLORPLOT
% plot the 'FreqSignal' elements as columns of a colorplot (data vs.
% freq bins). Each element must have the same Freq property
% valid only if number of dimensions <= 2 in Data property
% WARNING : if several channels are present, they will be averaged or
% superimposed. default : averaged
% INPUTS :
    % commonOptions : cell of key-values pairs for plot properties that will
    % be shared by plots of all channels
    % specificOptions : cell of key-values pairs for plot properties that
    % will are specific to each channels ; each values of key-value pair
    % must be cell of length nChannels
% OUTPUTS :
    % h : handle to the axes of the plot


function h = colorPlot(self, varargin)

% default outputs
h = [];

% args & options
if ~isempty(varargin)
    if ischar(varargin{1}) % kvPairs
        varargin = panam_args2struct(varargin);
    else % structure
        varargin = varargin{1};
    end
else
    varargin = [];
end
defaultOption.newFigure = 'yes'; % by default : a new figure is created
defaultOption.channels = 'grid'; % default : 1 subplot per channel
defaultOption.title = '';
defaultOption.colormap = 'lines'; % default colormap for plots
defaultOption.xaxis = 'auto';
defaultOption.markers = 'yes';
defaultOption.smooth = [1 1 1 1];% nb of points and std dev for gaussian smoothing. Default : no smoothing
defaultOption.markerColormap = 'lines'; % use the colormap 'lines' to draw markers
option = setstructfields(defaultOption, varargin);

% case empty
if isempty(self)
    if option.newFigure
        figure;
    end
    return;
end

% TODO : check inputs
if ~all(arrayfun(@isNumFreq, self)) || ~any(arrayfun(@isNumFreq, self))
    error('Freq property of the elements of the FreqSignal must be all numeric or all discrete');
end

% figure
if strcmpi(option.newFigure, 'yes')
    v = get(0, 'MonitorPosition'); % avoid Java isssues
    v1 = v(1,:);
    v1(1) = v1(1) - 1;
    sumX = sum(v(:,3));
    v1 = v1 ./ [sumX v1(4) sumX v1(4)]; % normalize
    figure('Name',option.title,'units','normalized','outerposition',v1)
end

% make self a column
self = self(:);

% check that Freq property is the same for each element of self
self = self.adjustFreq;

% init markers
if strcmpi(option.markers, 'yes')
    [markerNames, markerColors, legStatus, legLabels, legHandles] =  init_markers(self, option);
end

% create data
switch option.channels
    case 'superimpose'
        channels = {'All Channels'};
        tmp = [];
        markers{1} = {};
        for ii = 1:numel(self)
            tmp = cat(2, tmp, self(ii).Data);
            if strcmpi(option.markers, 'yes')
                markers{1}(end+1:end+size(self(ii).Data, 2)) = {self(ii).FreqMarkers};
            end
        end
        data = {tmp'};
    case 'grid'
        channels = arrayfun(@(x) x.ChannelTags, self, 'UniformOutput',0);
        [channels, order] = unique([channels{:}]);
        [~,order] = sort(order);
        channels = channels(order);
        for jj = 1:numel(channels)
            tmp = [];
            markers{jj} = {};
            for ii = 1:numel(self)
                indChan = find(strcmpi(self(ii).ChannelTags, channels{jj}),1);
                if ~isempty(indChan)
                    tmp = cat(2, tmp, self(ii).Data(:,indChan));
                    if strcmpi(option.markers, 'yes')
                        markers{jj}{end+1} = self(ii).FreqMarkers;
                    end
                end
            end
            data{jj} = tmp';
        end
end

% smooth data with gaussian filter
nPointsSmoothHor = option.smooth(1);
nPointsSmoothVert = option.smooth(2);
stdDevSmoothHor = option.smooth(3);
stdDevSmoothVert = option.smooth(4);
gaussFilter = customgauss([nPointsSmoothVert nPointsSmoothHor], stdDevSmoothVert, stdDevSmoothHor,0,0,1,[0 0]);
ratio = sum(sum(gaussFilter));
for ii = 1:numel(data)
    data{ii} = conv2(data{ii}, gaussFilter, 'same') / ratio;
end

% plot
[nH, nV] = panam_subplotDimensions(numel(data));
for ii = 1:numel(data)
    h(ii) = subplot(nH, nV, ii);
    hold on
    set(gca,'YDir','normal');
    if self(1).isNumFreq
        htmp = imagesc(self(1).Freq,[],data{ii});
    else
        htmp = imagesc(1:size(data,1),[],data{ii});
    end
    axis tight
    title(h(ii),channels(ii));
    set(htmp,'alphadata',~isnan(dataTmp));
end

% markers
if strcmpi(option.markers, 'yes')          
    for ii = 1:numel(h)
        [h(ii), legStatus, legLabels, legHandles] = plot_markers(h(ii), markers{ii}, markerNames, markerColors, legStatus, legLabels, legHandles);
        if strcmpi(option.markers, 'yes')
            legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
        end
    end
end

% axes properties
for ii = 1:numel(h)
    set(h(ii),'YTick',[]);
    xlabel(h(ii),'Freq')
    hold off
end

% xaxis
if ~isequal(option.xaxis, 'auto')
    for i = 1:length(h)
        xlim(h(i), option.xaxis);
    end
end

end



function [hOut, legStatusOut, legLabelsOut, legHandlesOut] = plot_markers(hIn, markers, markerNames, markerColors, legStatusIn, legLabelsIn, legHandlesIn)

hOut = hIn;
axes(hOut);
hold on

legStatusOut = legStatusIn;
legLabelsOut = legLabelsIn;
legHandlesOut = legHandlesIn;

% markers
if iscell(markers) % 1 marker for each data plot)
    for i = 1:numel(markers)
        for k = 1:numel(markers{i})
            ind = find(strcmp(markers{i}(k).EventName, markerNames));
            t1 = markers{i}(k).Freq;
            t2 = t1 + markers{i}(k).Window;
            minEv = i - 0.5;
            maxEv = i + 0.5;
            if t2 == t1 % Window = 0
                plot([t1 t2], [minEv maxEv],'color', markerColors{ind},'Tag',markers{i}(k).EventName,'LineWidth',1);
                ev = plot((t1+t2)/2, (minEv + maxEv)/2, '-*','color', markerColors{ind},'Tag',markers{i}(k).EventName,'LineWidth',1,'MarkerSize',4);
            else
                ev = fill([t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],markerColors{ind},'EdgeColor', markerColors{ind}, 'Tag',markers{i}(k).EventName, 'FaceAlpha', 0.2);
            end
            if legStatusOut(ind) == 0
                legHandlesOut(end+1) = ev;
                legLabelsOut(end+1) = {markers{i}(k).EventName};
                legStatusOut(ind) = 1;
            end
        end
    end
else % straightly markers structure : same markers for all plots of the gca
    for k = 1:numel(markers)
        ind = find(strcmp(markers(k).EventName, markerNames));
        t1 = markers(k).Freq;
        t2 = t1 + markers(k).Window;
        a = axis(hOut);
        minEv = a(3);
        maxEv = a(4);
        if t2 == t1 % Window = 0
            ev = plot([t1 t2], [minEv maxEv],'color', markerColors{ind},'Tag',markers(k).EventName,'LineWidth',1);
        else
            ev = fill([t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],markerColors{ind},'EdgeColor', markerColors{ind}, 'Tag',markers(k).EventName, 'FaceAlpha', 0.2);
        end
        if legStatusOut(ind) == 0
            legHandlesOut(end+1) = ev;
            legLabelsOut(end+1) = {markers(k).EventName};
            legStatusOut(ind) = 1;
        end
    end
end

end



function [markerNames, markerColors, legStatus, legLabels,legHandles] =  init_markers(self, option)

tmp = arrayfun(@(x) {x.FreqMarkers.MarkerName}, self, 'UniformOutput',0);
markerNames = unique([tmp{:}]);
evColorMap = option.markerColormap;
eval(['markerColors = ' evColorMap '(numel(markerNames));']);
markerColors = num2cell(markerColors,2);
legStatus = zeros(1,numel(markerNames)); % for legend
legLabels = {}; % associated legend entries
legHandles = [];

end