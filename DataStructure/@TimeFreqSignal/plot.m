% PLOT
% plot the average of 'TimeFreqSignal' elements (freq vs.
% time bins). Channels are averaged too. Each element must have the same Time property
% valid only if number of dimensions <= 2 in Data property
% WARNING : if several channels are present, they will be averaged. default : averaged
% INPUTS :
% OUTPUTS :
    % h : handle to the axes of the plot


function h = plot(self, varargin)

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
defaultOption.events = 'yes';
defaultOption.markers = 'yes';
defaultOption.smooth = [1 1 1 1];% nb of points and std dev for gaussian smoothing. Default : no smoothing
defaultOption.eventColormap = 'lines'; % use the colormap 'lines' to draw events
defaultOption.markerColormap = 'hsv'; % use the colormap 'hsv' to draw markers
option = setstructfields(defaultOption, varargin);

% case empty
if isempty(self)
    if option.newFigure
        figure;
    end
    return;
end

% check input
if ~(all(arrayfun(@isNumTime, self)) || ~any(arrayfun(@isNumTime, self)))
    error('Time property of the elements of the TimeFreqSignal must be all numeric or all discrete');
end
if ~(all(arrayfun(@isNumFreq, self)) || ~any(arrayfun(@isNumFreq, self)))
    error('Freq property of the elements of the TimeFreqSignal must be all numeric or all discrete');
end

% init events
if strcmpi(option.events, 'yes')
    [eventNames, eventColors, legStatusEv, legLabelsEv, legHandlesEv] =  init_events(self, option);
end

% init markers
if strcmpi(option.markers, 'yes')
    [markerNames, markerColors, legStatusFm, legLabelsFm, legHandlesFm] =  init_markers(self, option);
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

% average
self = self.avgElements;

% extract data
data = permute(self.Data,[2 1 3]); % new order : freq x time x channels

% smooth data with gaussian filter
% smooth data with gaussian filter
nPointsSmoothHor = option.smooth(1);
nPointsSmoothVert = option.smooth(2);
stdDevSmoothHor = option.smooth(3);
stdDevSmoothVert = option.smooth(4);
gaussFilter = customgauss([nPointsSmoothVert nPointsSmoothHor], stdDevSmoothVert, stdDevSmoothHor,0,0,1,[0 0]);
ratio = sum(sum(gaussFilter));
for ii = 1:size(data,3)
    data(:,:,ii) = conv2(data(:,:,ii), gaussFilter, 'same') / ratio;
end

% plot
[nH, nV] = panam_subplotDimensions(size(data,3));
for ii = 1:size(data,3)
    dataTmp = data(:,:,ii);
    h(ii) = subplot(nH, nV, ii);
    hold on
    set(gca,'YDir','normal');
    if self(1).isNumTime
        if self.isNumFreq
            imagesc(self.Time,self.Freq,dataTmp);
        else
            imagesc(self.Time,1:size(dataTmp,1),dataTmp);
        end
    else
        if self.isNumFreq
            imagesc(1:size(dataTmp,2),self.Freq,dataTmp);
        else
            imagesc(1:size(dataTmp,2),1:size(dataTmp,1),dataTmp);
        end
    end
    axis tight
    title(h(ii),self.ChannelTags{ii});
end

% events
if strcmpi(option.events, 'yes')
    for ii = 1:numel(h)
        [h(ii), legStatusEv, legLabelsEv, legHandlesEv] = plot_events(h(ii), self.Events, eventNames, eventColors, legStatusEv, legLabelsEv, legHandlesEv);
    end
end

% markers
if strcmpi(option.markers, 'yes')
    for ii = 1:numel(h)
        [h(ii), legStatusFm, legLabelsFm, legHandlesFm] = plot_markers(h(ii), self.FreqMarkers, markerNames, markerColors, legStatusFm, legLabelsFm, legHandlesFm);
    end
end

if strcmpi(option.events, 'yes')
    if strcmpi(option.markers, 'yes')
        legend([legHandlesEv, legHandlesFm], [legLabelsEv,legLabelsEv], 'Position', [0.94 0.85 0.03 0.1]);
    else
        legend(legHandlesEv, legLabelsEv, 'Position', [0.94 0.85 0.03 0.1]);
    end
else
    if strcmpi(option.markers, 'yes')
        legend(legHandlesFm, legLabelsFm, 'Position', [0.94 0.85 0.03 0.1]);
    else
         legend hide % no legend
    end
end
        
        
% axes properties
for ii = 1:numel(h)
    xlabel(h(ii),'Time')
    ylabel(h(ii),'Freq')
    hold off
    if ~self.isNumTime
        set(h(ii),'XTick',1:length(self.Time), 'XTickLabel', self.Time);
    end
    if ~self.isNumFreq
        set(h(ii),'YTick',1:length(self.Freq), 'YTickLabel', self.Freq);
    end
end

% xaxis
if ~isequal(option.xaxis, 'auto')
    for i = 1:length(h)
        xlim(h(i), option.xaxis);
    end
end

end


function [hOut, legStatusOut, legLabelsOut, legHandlesOut] = plot_events(hIn, events, eventNames, eventColors, legStatusIn, legLabelsIn, legHandlesIn)

hOut = hIn;
axes(hOut);
hold on

legStatusOut = legStatusIn;
legLabelsOut = legLabelsIn;
legHandlesOut = legHandlesIn;


for k = 1:numel(events)
    ind = find(strcmp(events(k).EventName, eventNames));
    t1 = events(k).Time;
    t2 = t1 + events(k).Duration;
    a = axis(hOut);
    minEv = a(3);
    maxEv = a(4);
    if t2 == t1 % Duration = 0
        plot([t1 t2], [minEv maxEv],'color', eventColors{ind},'Tag',events(k).EventName,'LineWidth',1);
        ev = plot((t1+t2)/2, (minEv + maxEv)/2,'color', eventColors{ind},'Tag',events(k).EventName,'LineWidth',1,'MarkerSize',4);
    else
        ev = fill([t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],eventColors{ind},'EdgeColor', eventColors{ind}, 'Tag',events(k).EventName, 'FaceAlpha', 0.2);
    end
    if legStatusOut(ind) == 0
        legHandlesOut(end+1) = ev;
        legLabelsOut(end+1) = {events(k).EventName};
        legStatusOut(ind) = 1;
    end
end

end



function [eventNames, eventColors, legStatus, legLabels,legHandles] =  init_events(self, option)

tmp = arrayfun(@(x) {x.Events.EventName}, self, 'UniformOutput',0);
eventNames = unique([tmp{:}]);
evColorMap = option.eventColormap;
eval(['eventColors = ' evColorMap '(numel(eventNames));']);
eventColors = num2cell(eventColors,2);
legStatus = zeros(1,numel(eventNames)); % for legend
legLabels = {}; % associated legend entries
legHandles = [];

end


function [hOut, legStatusOut, legLabelsOut, legHandlesOut] = plot_markers(hIn, markers, markerNames, markerColors, legStatusIn, legLabelsIn, legHandlesIn)

hOut = hIn;
axes(hOut);
hold on

legStatusOut = legStatusIn;
legLabelsOut = legLabelsIn;
legHandlesOut = legHandlesIn;

% markers
for k = 1:numel(markers)
    ind = find(strcmp(markers(k).EventName, markerNames));
    t1 = markers(k).Freq;
    t2 = t1 + markers(k).Window;
    a = axis(hOut);
    minEv = a(3);
    maxEv = a(4);
    if t2 == t1 % Window = 0
        ev = plot([t1 t2], [minEv maxEv],'color', markerColors{ind},'Tag',markers{i}(k).EventName,'LineWidth',1);
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


