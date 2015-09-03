% PLOT
% plot the 'TimeSignal' as data vs. time bins
% valid only if number of dimensions <= 2 in Data property
% plot the different channels on the same plot
% INPUTS :
    % commonOptions : cell of key-values pairs for plot properties that will
    % be shared by plots of all channels
    % specificOptions : cell of key-values pairs for plot properties that
    % are specific to each channel ; each values of key-value pair
    % must be a cell of length nChannels
% OUTPUTS :
    % h : handle to the axes of the plot


function [h, ev] = plot(self, varargin)

% default outputs
h = [];
ev = [];

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
defaultOption.title = '';
defaultOption.channels = 'grid';
defaultOption.signals = 'list';%'superimpose';
defaultOption.uniqueAxes = 0; %0; % in case of list -> if 1, all in one axes or not ? If 1, impossible to change between-signals y-axis, but x-axis is updated for all signals
defaultOption.nColumns = 1; % number of columns for lists
defaultOption.colormap = 'lines'; % default colormap for plots
defaultOption.xAxis = 'auto';
defaultOption.yAxis = 'auto';
defaultOption.events = 'yes';
defaultOption.eventLabel = 'yes'; % put a label with the name of the event next to the event
defaultOption.eventColormap = 'lines'; % use the colormap 'lines' to draw events
option = setstructfields(defaultOption, varargin);

% case empty
if isempty(self)
    if option.newFigure
        figure;
    end
    return;
end

% TODO : check inputs
if ~all(arrayfun(@isNumTime, self)) || ~any(arrayfun(@isNumTime, self))
    error('Time property of the elements of the TimeSignal must be all numeric or all discrete');
end

% make self a column
self = self(:);

% case where there is more than 2 dimensions in Data property : select
% first one
if ~strcmpi(option.signals, 'confint')
    for i = 1:numel(self)
        self(i).Data = self(i).Data(:,:,1);
    end
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

% plot
switch option.channels
    case 'list'
        switch option.signals
            case 'list'
                if option.uniqueAxes
                    % plot signals
                    ytick = [];
                    ytickLabel = {};
                    count = 0;
                    interval = 1.5*max(arrayfun(@(x) max(abs(x.Data(:))), self));
                    h = axes();
                    xlabel('Time');
                    hold on
                    for i = 1:numel(self)
                        for j = 1:numel(self(i).ChannelTags)
                            plot(self(i).Time, self(i).Data(:,j) - count * interval);
                            ytick(end+1) = nanmean(self(i).Data(:,j)) - count * interval;
                            ytickLabel(end+1) = {['Signal' num2str(i) ' - Channel ' self(i).ChannelTags{j}]};
                            count = count + 1;
                        end
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        tmp = arrayfun(@(x) {x.Events.EventName}, self, 'UniformOutput',0);
                        eventNames = unique([tmp{:}]);
                        evColorMap = option.eventColormap;
                        eval(['evColor = ' evColorMap '(numel(eventNames));']);
                        evColor = num2cell(evColor,2);
                        eventCount = zeros(1,numel(eventNames)); % for legend
                        ev = [];
                        countEv = 0;
                        indEvLegend = []; % indices of ev handle-struct that will go into legend
                        legendLabels = {}; % associated legend entries
                        for i = 1:numel(self)
                            self(i).Events = self(i).Events.sortByTime;
                            for k = 1:numel(self(i).Events)
                                ind = find(strcmp(self(i).Events(k).EventName, eventNames));
                                t1 = self(i).Events(k).Time;
                                t2 = t1 + self(i).Events(k).Duration;
                                minEv = min(self(i).Data(:,end)) - (countEv + numel(self(i).ChannelTags)-1) * interval;
                                maxEv = max(self(i).Data(:,1)) - countEv * interval;
                                if t2 == t1 % Duration = 0
                                    ev(end+1) = plot([t1,t2], [minEv maxEv], 'color', evColor{ind},'Tag',self(i).Events(k).EventName, 'LineWidth',2);
                                else
                                    ev(end+1) = fill([t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName, 'FaceAlpha', 0.2);
%                                     ev(end+1) = area([t1,t2], [maxEv maxEv],minEv, 'FaceColor', evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName);
%                                     alpha(0.2);
                                end
                                if eventCount(ind) == 0
                                    indEvLegend(end+1) = numel(ev); % index of considered ev-handle
                                    legendLabels(end+1) = {self(i).Events(k).EventName};
                                    eventCount(ind) = 1;
                                end
                            end
                            countEv = countEv + numel(self(i).ChannelTags);
                        end
                        legend(ev(indEvLegend), legendLabels, 'Location', 'NorthEastOutside');
                    end
                    % axes properties
                    ytick = ytick(end:-1:1); % reverse
                    ytickLabel = ytickLabel(end:-1:1);
                    set(gca, 'Ticklength', [0.002 0.005]);
                    set(gca, 'YTick', ytick);
                    set(gca, 'YTickLabel', ytickLabel);
                    axis tight
                    a = axis;
                    axis([a(1:2) a(3)-0.05*abs(a(4)-a(3))  a(4)+0.05*abs(a(4)-a(3))]);
                else % one axes for each plot
                    % axes properties
                    nAxes = 0;
                    xmin = +Inf;
                    xmax = -Inf;
                    for i = 1:numel(self);
                        nAxes = nAxes + numel(self(i).ChannelTags);
                        xmin = min(xmin, self(i).Time(1));
                        xmax = max(xmax, self(i).Time(end));
                    end
                    interval = 0.9 / nAxes;
                    % plot signals
                    count = 0;
                    for i = numel(self):-1:1
                        for j = numel(self(i).ChannelTags):-1:1
                            h(count+1) = axes('Position', [0.1 0.05+count*interval 0.8 interval]);
                            hold on
                            plot(self(i).Time, self(i).Data(:,j));
                            ymin = min(self(i).Data(:,j));
                            ymax = max(self(i).Data(:,j));
                            delta = ymax - ymin;
                            ymin = ymin - 0.1*delta;
                            ymax = ymax + 0.1*delta;
                            axis([xmin xmax ymin ymax]);
                            a = axis;
                            ytick = mean(a(3:4)); % reverse
                            ytickLabel = {['Signal' num2str(i) ' - Channel ' self(i).ChannelTags{j}]};
                            set(gca, 'Ticklength', [0.002 0.005]);
                            set(gca, 'YTick', ytick);
                            set(gca, 'YTickLabel', ytickLabel);
                            % increment count
                            count = count + 1;
                        end
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        tmp = arrayfun(@(x) {x.Events.EventName}, self, 'UniformOutput',0);
                        eventNames = unique([tmp{:}]);
                        evColorMap = option.eventColormap;
                        eval(['evColor = ' evColorMap '(numel(eventNames));']);
                        evColor = num2cell(evColor,2);
                        eventCount = zeros(1,numel(eventNames)); % for legend
                        ev = [];
                        countEv = 0;
                        indEvLegend = []; % indices of ev handle-struct that will go into legend
                        legendLabels = {}; % associated legend entries
                        for i = numel(self):-1:1
                            self(i).Events = self(i).Events.sortByTime;
                            for j = numel(self(i).ChannelTags):-1:1
                                for k = 1:numel(self(i).Events)
                                    ind = find(strcmp(self(i).Events(k).EventName, eventNames));
                                    t1 = self(i).Events(k).Time;
                                    t2 = t1 + self(i).Events(k).Duration;
                                    a = axis(h(countEv+1));
                                    minEv = a(3);
                                    maxEv = a(4);
                                    if t2 == t1 % Duration = 0
                                        ev(end+1) = plot(h(countEv+1),[t1,t2], [minEv maxEv], 'color', evColor{ind},'Tag',self(i).Events(k).EventName, 'LineWidth',2);
                                    else
                                        ev(end+1) = fill(h(countEv+1),[t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName, 'FaceAlpha', 0.2);
%                                         ev(end+1) = area(h(countEv+1), [t1,t2], [maxEv maxEv],minEv, 'FaceColor', evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName);
%                                         alpha(0.2);
                                    end
                                    if eventCount(ind) == 0
                                        indEvLegend(end+1) = numel(ev); % index of considered ev-handle
                                        legendLabels(end+1) = {self(i).Events(k).EventName};
                                        eventCount(ind) = 1;
                                    end
                                end
                                countEv = countEv + 1;
                            end
                        end
                        legend(ev(indEvLegend), legendLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                    % axes properties
                    xlabel(h(1), 'Time');
                end
            case 'grid'
                if option.uniqueAxes
                    nPlots = numel(self);
                    [nH, nV] = panam_subplotDimensions(nPlots);
                    % plot signals
                    for i = 1:numel(self)
                        h(i) = subplot(nH, nV, i);
                        hold on
                        count = 0;
                        interval = 1.5*max(abs(self(i).Data(:)));
                        ytick = [];
                        ytickLabel = {};
                        for j = 1:numel(self(i).ChannelTags)
                            plot(self(i).Time, self(i).Data(:,j) - count * interval);
                            ytick(end+1) = nanmean(self(i).Data(:,j)) - count * interval;
                            ytickLabel(end+1) = {['Channel ' self(i).ChannelTags{j}]};
                            count = count + 1;
                        end
                        xlabel('Time');
                        title(['Signal ' num2str(i)]);
                        ytick = ytick(end:-1:1); % reverse
                        ytickLabel = ytickLabel(end:-1:1);
                        set(gca, 'Ticklength', [0.002 0.005]);
                        set(gca, 'YTick', ytick);
                        set(gca, 'YTickLabel', ytickLabel);
                        axis tight
                        a = axis;
                        axis([a(1:2) a(3)-0.05*abs(a(4)-a(3))  a(4)+0.05*abs(a(4)-a(3))]);
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        tmp = arrayfun(@(x) {x.Events.EventName}, self, 'UniformOutput',0);
                        eventNames = unique([tmp{:}]);
                        evColorMap = option.eventColormap;
                        eval(['evColor = ' evColorMap '(numel(eventNames));']);
                        evColor = num2cell(evColor,2);
                        eventCount = zeros(1,numel(eventNames)); % for legend
                        ev = [];
                        indEvLegend = []; % indices of ev handle-struct that will go into legend
                        legendLabels = {}; % associated legend entries
                        for i = 1:numel(self)
                            self(i).Events = self(i).Events.sortByTime;
                            for k = 1:numel(self(i).Events)
                                ind = find(strcmp(self(i).Events(k).EventName, eventNames));
                                t1 = self(i).Events(k).Time;
                                t2 = t1 + self(i).Events(k).Duration;
                                a = axis(h(i));
                                minEv = a(3);
                                maxEv = a(4);
                                if t2 == t1 % Duration = 0
                                    ev(end+1) = plot(h(i),[t1,t2], [minEv maxEv], 'color', evColor{ind},'Tag',self(i).Events(k).EventName, 'LineWidth',2);
                                else
                                    ev(end+1) = fill(h(i),[t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName, 'FaceAlpha', 0.2);
%                                     ev(end+1) = area(h(i),[t1,t2], [maxEv maxEv],minEv, 'FaceColor', evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName);
%                                     alpha(0.2);
                                end
                                if eventCount(ind) == 0
                                    indEvLegend(end+1) = numel(ev); % index of considered ev-handle
                                    legendLabels(end+1) = {self(i).Events(k).EventName};
                                    eventCount(ind) = 1;
                                end
                            end
                        end
                        legend(ev(indEvLegend), legendLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                    % axes properties
                else
                    [nH, nV] = panam_subplotDimensions(numel(self));
                    count = 0;
                    % plot signals
                    for i = 1:numel(self)
                        hTemp = subplot(nH, nV, i);
                        pos = get(hTemp, 'Position');
                        delete(hTemp);
                        yInterval = pos(4) / numel(self(i).ChannelTags);
                        xmin = self(i).Time(1);
                        xmax = self(i).Time(end);
                        for j = numel(self(i).ChannelTags):-1:1
                            h(count+1) = axes('Position', [pos(1) pos(2)+(numel(self(i).ChannelTags)-j)*yInterval pos(3) yInterval]);
                            hold on
                            plot(self(i).Time, self(i).Data(:,j));
                            ymin = min(self(i).Data(:,j));
                            ymax = max(self(i).Data(:,j));
                            delta = ymax - ymin;
                            ymin = ymin - 0.1*delta;
                            ymax = ymax + 0.1*delta;
                            axis([xmin xmax ymin ymax]);
                            a = axis;
                            ytick = mean(a(3:4)); % reverse
                            ytickLabel = {['Channel ' self(i).ChannelTags{j}]};
                            set(gca, 'Ticklength', [0.002 0.005]);
                            set(gca, 'YTick', ytick);
                            set(gca, 'YTickLabel', ytickLabel);
                            % increment count
                            count = count + 1;
                        end
                        xlabel(h(count+1-numel(self(i).ChannelTags)),'Time');
                        title(h(count),['Signal ' num2str(i)]);
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        tmp = arrayfun(@(x) {x.Events.EventName}, self, 'UniformOutput',0);
                        eventNames = unique([tmp{:}]);
                        evColorMap = option.eventColormap;
                        eval(['evColor = ' evColorMap '(numel(eventNames));']);
                        evColor = num2cell(evColor,2);
                        eventCount = zeros(1,numel(eventNames)); % for legend
                        ev = [];
                        indEvLegend = []; % indices of ev handle-struct that will go into legend
                        legendLabels = {}; % associated legend entries
                        countEv = 0;
                        for i = 1:numel(self)
                            self(i).Events = self(i).Events.sortByTime;
                            for j = numel(self(i).ChannelTags):-1:1
                                for k = 1:numel(self(i).Events)
                                    ind = find(strcmp(self(i).Events(k).EventName, eventNames));
                                    t1 = self(i).Events(k).Time;
                                    t2 = t1 + self(i).Events(k).Duration;
                                    a = axis(h(countEv+1));
                                    minEv = a(3);
                                    maxEv = a(4);
                                    if t2 == t1 % Duration = 0
                                        ev(end+1) = plot(h(countEv+1),[t1,t2], [minEv maxEv], 'color', evColor{ind},'Tag',self(i).Events(k).EventName, 'LineWidth',2);
                                    else
                                        ev(end+1) = fill(h(countEv+1),[t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName, 'FaceAlpha', 0.2);
%                                         ev(end+1) = area(h(countEv+1),[t1,t2], [maxEv maxEv],minEv, 'FaceColor', evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName);
%                                         alpha(0.2);
                                    end
                                    if eventCount(ind) == 0
                                        indEvLegend(end+1) = numel(ev); % index of considered ev-handle
                                        legendLabels(end+1) = {self(i).Events(k).EventName};
                                        eventCount(ind) = 1;
                                    end
                                end
                                countEv = countEv + 1;
                            end
                        end
                        legend(ev(indEvLegend), legendLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                    % axes properties
                end
            case 'superimpose'
                if option.uniqueAxes
                    % plot signals
                    ytick = [];
                    ytickLabel = {};
                    count = 0;
                    interval = 1.5*max(arrayfun(@(x) max(abs(x.Data(:))), self));
                    h = axes();
                    xlabel('Time');
                    hold on
                    channels = arrayfun(@(x) x.ChannelTags, self, 'UniformOutput',0);
                    [channels, order] = unique([channels{:}]);
                    [~,order] = sort(order);
                    channels = channels(order);
                    signalColorMap = option.colormap;
                    eval(['signalColor = ' signalColorMap '(numel(self));']);
                    signalColor = num2cell(signalColor,2);
                    for j = 1:numel(channels)
                        means = [];
                        for i = 1:numel(self)
                            indChan = find(strcmpi(self(i).ChannelTags, channels{j}));
                            if ~isempty(indChan)
                                plot(self(i).Time, self(i).Data(:,indChan) - count * interval, 'color',signalColor{i});
                                means(end+1) = nanmean(self(i).Data(:,indChan) - count * interval);
                            end
                        end
                        ytick(end+1) = mean(means);
                        ytickLabel(end+1) = {['Channel ' self(i).ChannelTags{indChan}]};
                        count = count + 1;
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        indEvLegend = []; % indices of ev handle-struct that will go into legend
                        legendLabels = {}; % associated legend entries
                        tmpEvents = self.avgElements.Events.sortByTime;
                        eventNames = {tmpEvents.EventName};
                        evColorMap = option.eventColormap;
                        eval(['evColor = ' evColorMap '(numel(eventNames));']);
                        evColor = num2cell(evColor,2);
                        eventCount = zeros(1,numel(eventNames)); % for legend
                        ev = [];
                        for k = 1:numel(tmpEvents)
                            ind = find(strcmp(tmpEvents(k).EventName, eventNames));
                            t1 = tmpEvents(ind).Time;
                            t2 = t1 + tmpEvents(ind).Duration;
                            minEv = ytick(end) - interval / 2;
                            maxEv = ytick(1) + interval / 2;
                            if t2 == t1 % Duration = 0
                                ev(end+1) = plot([t1,t2], [minEv maxEv], 'color', evColor{ind},'Tag',self(i).Events(k).EventName, 'LineWidth',2);
                            else
                                ev(end+1) = fill([t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName, 'FaceAlpha', 0.2);
%                                 ev(end+1) = area([t1,t2], [maxEv maxEv],minEv, 'FaceColor', evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName, 'FaceAlpha', 0.2);
%                                 alpha(0.2);
                            end
                            if eventCount(ind) == 0
                                indEvLegend(end+1) = numel(ev); % index of considered ev-handle
                                legendLabels(end+1) = {self(i).Events(k).EventName};
                                eventCount(ind) = 1;
                            end
                        end
                        legend(ev(indEvLegend), legendLabels, 'Location', 'NorthEastOutside');
                    end
                    % axes properties
                    ytick = ytick(end:-1:1); % reverse
                    ytickLabel = ytickLabel(end:-1:1);
                    set(gca, 'Ticklength', [0.002 0.005]);
                    set(gca, 'YTick', ytick);
                    set(gca, 'YTickLabel', ytickLabel);
                    axis tight
                    a = axis;
                    axis([a(1:2) a(3)-0.05*abs(a(4)-a(3))  a(4)+0.05*abs(a(4)-a(3))]);
                else % one axes for each plot
                    % axes properties
                    nAxes = 0;
                    xmin = +Inf;
                    xmax = -Inf;
                    for i = 1:numel(self);
                        nAxes = nAxes + numel(self(i).ChannelTags);
                        xmin = min(xmin, self(i).Time(1));
                        xmax = max(xmax, self(i).Time(end));
                    end
                    interval = 0.9 / nAxes;
                    % plot signals
                    count = 0;
                    for i = numel(self):-1:1
                        for j = numel(self(i).ChannelTags):-1:1
                            h(count+1) = axes('Position', [0.1 0.05+count*interval 0.8 interval]);
                            hold on
                            plot(self(i).Time, self(i).Data(:,j));
                            ymin = min(self(i).Data(:,j));
                            ymax = max(self(i).Data(:,j));
                            delta = ymax - ymin;
                            ymin = ymin - 0.1*delta;
                            ymax = ymax + 0.1*delta;
                            axis([xmin xmax ymin ymax]);
                            a = axis;
                            ytick = mean(a(3:4)); % reverse
                            ytickLabel = {['Signal' num2str(i) ' - Channel ' self(i).ChannelTags{j}]};
                            set(gca, 'Ticklength', [0.002 0.005]);
                            set(gca, 'YTick', ytick);
                            set(gca, 'YTickLabel', ytickLabel);
                            % increment count
                            count = count + 1;
                        end
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        tmp = arrayfun(@(x) {x.Events.EventName}, self, 'UniformOutput',0);
                        eventNames = unique([tmp{:}]);
                        evColorMap = option.eventColormap;
                        eval(['evColor = ' evColorMap '(numel(eventNames));']);
                        evColor = num2cell(evColor,2);
                        eventCount = zeros(1,numel(eventNames)); % for legend
                        ev = [];
                        countEv = 0;
                        indEvLegend = []; % indices of ev handle-struct that will go into legend
                        legendLabels = {}; % associated legend entries
                        for i = numel(self):-1:1
                            self(i).Events = self(i).Events.sortByTime;
                            for j = numel(self(i).ChannelTags):-1:1
                                for k = 1:numel(self(i).Events)
                                    ind = find(strcmp(self(i).Events(k).EventName, eventNames));
                                    t1 = self(i).Events(k).Time;
                                    t2 = t1 + self(i).Events(k).Duration;
                                    a = axis(h(countEv+1));
                                    minEv = a(3);
                                    maxEv = a(4);
                                    if t2 == t1 % Duration = 0
                                        ev(end+1) = plot(h(countEv+1),[t1,t2], [minEv maxEv], 'color', evColor{ind},'Tag',self(i).Events(k).EventName, 'LineWidth',2);
                                    else
                                        ev(end+1) = fill(h(countEv+1),[t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName, 'FaceAlpha', 0.2);
%                                         ev(end+1) = area(h(countEv+1), [t1,t2], [maxEv maxEv],minEv, 'FaceColor', evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(i).Events(k).EventName);
%                                         alpha(0.2);
                                    end
                                    if eventCount(ind) == 0
                                        indEvLegend(end+1) = numel(ev); % index of considered ev-handle
                                        legendLabels(end+1) = {self(i).Events(k).EventName};
                                        eventCount(ind) = 1;
                                    end
                                end
                                countEv = countEv + 1;
                            end
                        end
                        legend(ev(indEvLegend), legendLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                    % axes properties
                    xlabel(h(1), 'Time');
                end
            case 'avg'
                defaultOption.avgOptions = {}; % use default avgOptions
                option = setstructfields(defaultOption, varargin);
                try option.avgOptions = panam_args2struct(option.avgOptions);end;
                self = self.avgElements(option.avgOptions);
                option.signals = 'list';
                [h, ev] = self.plot(option);
            case 'confint'
                % first add in avgElements the possibility to compute the
                % standard deviation or other deviation / error metrics
                % then call confplot on the structure
                defaultOption.avgOptions = {}; % use default avgOptions
                option = setstructfields(defaultOption, varargin);
                option.avgOptions(end+1:end+2) = {'confint','stddev'};
                try option.avgOptions = panam_args2struct(option.avgOptions);end;
                if ~isequal(self(1).DimOrder{end-1}, 'confint')
                    self = self.avgElements(option.avgOptions);
                end
                % plot 
                if option.uniqueAxes
                    % plot signals
                    ytick = [];
                    ytickLabel = {};
                    count = 0;
                    interval = 1.5*max(arrayfun(@(x) max(abs(x.Data(:))), self));
                    h = axes();
                    xlabel('Time');
                    hold on
                    for j = 1:numel(self.ChannelTags)
                        if size(self.Data,2) == 2
                            confplot(self.Time, self.Data(:,1,j) - count * interval, self.Data(:,2,j)); % symetric error
                        else
                            confplot(self.Time, self.Data(:,1,j) - count * interval, self.Data(:,2,j), self.Data(:,3,j)); % lower and upper error
                        end
                        hold on
                        ytick(end+1) = nanmean(self.Data(:,1,j)) - count * interval;
                        ytickLabel(end+1) = {['Channel ' self.ChannelTags{j}]};
                        count = count + 1;
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        tmp = arrayfun(@(x) {x.Events.EventName}, self, 'UniformOutput',0);
                        eventNames = unique([tmp{:}]);
                        evColorMap = option.eventColormap;
                        eval(['evColor = ' evColorMap '(numel(eventNames));']);
                        evColor = num2cell(evColor,2);
                        eventCount = zeros(1,numel(eventNames)); % for legend
                        ev = [];
                        indEvLegend = []; % indices of ev handle-struct that will go into legend
                        legendLabels = {}; % associated legend entries
                        self.Events = self.Events.sortByTime;
                        for k = 1:numel(self.Events)
                            ind = find(strcmp(self.Events(k).EventName, eventNames));
                            t1 = self.Events(k).Time;
                            t2 = t1 + self.Events(k).Duration;
                            minEv = min(self.Data(:,1,end)) - (numel(self.ChannelTags)-1) * interval;
                            maxEv = max(self.Data(:,1,1));
                            if t2 == t1 % Duration = 0
                                ev(end+1) = plot([t1,t2], [minEv maxEv], 'color', evColor{ind},'Tag',self.Events(k).EventName, 'LineWidth',2);
                            else
                                ev(end+1) = fill([t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self.Events(k).EventName, 'FaceAlpha', 0.2);
%                                 ev(end+1) = area([t1,t2], [maxEv maxEv],minEv, 'FaceColor', evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self.Events(k).EventName);
%                                 alpha(0.2);
                            end
                            if eventCount(ind) == 0
                                indEvLegend(end+1) = numel(ev); % index of considered ev-handle
                                legendLabels(end+1) = {self.Events(k).EventName};
                                eventCount(ind) = 1;
                            end
                        end
                        legend(ev(indEvLegend), legendLabels, 'Location', 'NorthEastOutside');
                    end
                    % axes properties
                    ytick = ytick(end:-1:1); % reverse
                    ytickLabel = ytickLabel(end:-1:1);
                    set(gca, 'Ticklength', [0.002 0.005]);
                    set(gca, 'YTick', ytick);
                    set(gca, 'YTickLabel', ytickLabel);
                    axis tight
                    a = axis;
                    axis([a(1:2) a(3)-0.05*abs(a(4)-a(3))  a(4)+0.05*abs(a(4)-a(3))]);
                else % one axes for each plot
                    % axes properties
                    nAxes = numel(self.ChannelTags);
                    xmin = self.Time(1);
                    xmax = self.Time(end);
                    interval = 0.9 / nAxes;
                    % plot signals
                    count = 0;
                    for j = numel(self.ChannelTags):-1:1
                        h(count+1) = axes('Position', [0.1 0.05+count*interval 0.8 interval]);
                        hold on
                        if size(self.Data,2) == 2
                            confplot(self.Time, self.Data(:,1,j), self.Data(:,2,j)); % symetric error
                            ymin = min(self.Data(:,1,j) - self.Data(:,2,j));
                            ymax = max(self.Data(:,1,j) + self.Data(:,2,j));
                        else
                            confplot(self.Time, self.Data(:,1,j), self.Data(:,2,j), self.Data(:,3,j)); % lower and upper error
                            ymin = min(self.Data(:,1,j) - self.Data(:,2,j));
                            ymax = max(self.Data(:,1,j) + self.Data(:,3,j));
                        end
                        hold on
                        delta = ymax - ymin;
                        ymin = ymin - 0.1*delta;
                        ymax = ymax + 0.1*delta;
                        axis([xmin xmax ymin ymax]);
                        a = axis;
                        ytick = mean(a(3:4)); % reverse
                        ytickLabel = {['Channel ' self.ChannelTags{j}]};
                        set(gca, 'Ticklength', [0.002 0.005]);
                        set(gca, 'YTick', ytick);
                        set(gca, 'YTickLabel', ytickLabel);
                        % increment count
                        count = count + 1;
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        tmp = arrayfun(@(x) {x.Events.EventName}, self, 'UniformOutput',0);
                        eventNames = unique([tmp{:}]);
                        evColorMap = option.eventColormap;
                        eval(['evColor = ' evColorMap '(numel(eventNames));']);
                        evColor = num2cell(evColor,2);
                        eventCount = zeros(1,numel(eventNames)); % for legend
                        ev = [];
                        countEv = 0;
                        indEvLegend = []; % indices of ev handle-struct that will go into legend
                        legendLabels = {}; % associated legend entries
                        self.Events = self.Events.sortByTime;
                        for j = numel(self.ChannelTags):-1:1
                            for k = 1:numel(self.Events)
                                ind = find(strcmp(self.Events(k).EventName, eventNames));
                                t1 = self.Events(k).Time;
                                t2 = t1 + self.Events(k).Duration;
                                a = axis(h(countEv+1));
                                minEv = a(3);
                                maxEv = a(4);
                                if t2 == t1 % Duration = 0
                                    ev(end+1) = plot(h(countEv+1),[t1,t2], [minEv maxEv], 'color', evColor{ind},'Tag',self.Events(k).EventName, 'LineWidth',2);
                                else
                                    axes(h(countEv+1));
                                    ev(end+1) = fill([t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self.Events(k).EventName, 'FaceAlpha', 0.2);
%                                                                              ev(end+1) = area( [t1,t2], [maxEv maxEv],minEv, 'FaceColor', evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self.Events(k).EventName);
                                    %                                         alpha(0.2);
                                end
                                if eventCount(ind) == 0
                                    indEvLegend(end+1) = numel(ev); % index of considered ev-handle
                                    legendLabels(end+1) = {self.Events(k).EventName};
                                    eventCount(ind) = 1;
                                end
                            end
                            countEv = countEv + 1;
                        end
                        legend(ev(indEvLegend), legendLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                    % axes properties
                    xlabel(h(1), 'Time');
                end
        end
        
        
        
    case 'grid'
        switch option.signals
            case 'list'
                if option.uniqueAxes
                    channels = arrayfun(@(x) x.ChannelTags, self, 'UniformOutput',0);
                    [channels, order] = unique([channels{:}]);
                    [~,order] = sort(order);
                    channels = channels(order);
                    nPlots = numel(channels);
                    [nH, nV] = panam_subplotDimensions(nPlots);
                    % plot signals
                    for i = 1:numel(channels)
                        % first : get data
                        data{i}  = [];
                        indSignals{i} = [];
                        for j = 1:numel(self)
                            indCh = find(strcmp(self(j).ChannelTags, channels{i}));
                            if ~isempty(indCh)
                                data{i}(:,end+1) = self(i).Data(:,indCh);
                                indSignals{i}(end+1) = j;
                            end
                        end
                        interval{i} = 1.5*max(abs(data{i}(:)));
                        clear data
                        % plot
                        h(i) = subplot(nH, nV, i);
                        hold on
                        count = 0;
                        ytick = [];
                        ytickLabel = {};
                        for j = indSignals{i}
                            indCh = find(strcmp(self(j).ChannelTags, channels{i}));
                            plot(self(j).Time, self(j).Data(:,indCh) - count * interval{i});
                            ytick(end+1) = nanmean(self(i).Data(:,indCh)) - count * interval{i};
                            ytickLabel(end+1) = {['Signal' num2str(j)]};
                            count = count + 1;
                        end
                        xlabel('Time');
                        title(channels{i});
                        ytick = ytick(end:-1:1); % reverse
                        ytickLabel = ytickLabel(end:-1:1);
                        set(gca, 'Ticklength', [0.002 0.005]);
                        set(gca, 'YTick', ytick);
                        set(gca, 'YTickLabel', ytickLabel);
                        axis tight
                        a = axis;
                        axis([a(1:2) a(3)-0.05*abs(a(4)-a(3))  a(4)+0.05*abs(a(4)-a(3))]);
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        tmp = arrayfun(@(x) {x.Events.EventName}, self, 'UniformOutput',0);
                        eventNames = unique([tmp{:}]);
                        evColorMap = option.eventColormap;
                        eval(['evColor = ' evColorMap '(numel(eventNames));']);
                        evColor = num2cell(evColor,2);
                        eventCount = zeros(1,numel(eventNames)); % for legend
                        ev = [];
                        indEvLegend = []; % indices of ev handle-struct that will go into legend
                        legendLabels = {}; % associated legend entries
                        for i = 1:numel(channels)
                            axes(h(i));
                            count = 0;
                            for j = indSignals{i}
                                indCh = find(strcmp(self(j).ChannelTags, channels{i}));
                                for k = 1:numel(self(j).Events)
                                    ind = find(strcmp(self(j).Events(k).EventName, eventNames));
                                    t1 = self(j).Events(k).Time;
                                    t2 = t1 + self(j).Events(k).Duration;
                                    minEv = nanmean(self(j).Data(:,indCh)) - (count+0.5)* interval{i};
                                    maxEv = nanmean(self(j).Data(:,indCh)) - (count-0.5)* interval{i};
                                    if t2 == t1 % Duration = 0
                                        ev(end+1) = plot([t1,t2], [minEv maxEv], 'color', evColor{ind},'Tag',self(j).Events(k).EventName, 'LineWidth',2);
                                    else
                                        ev(end+1) = fill([t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(j).Events(k).EventName, 'FaceAlpha', 0.2);
                                    end
                                    if eventCount(ind) == 0
                                        indEvLegend(end+1) = numel(ev); % index of considered ev-handle
                                        legendLabels(end+1) = {self(j).Events(k).EventName};
                                        eventCount(ind) = 1;
                                    end
                                end
                                count = count + 1;
                            end
                        end
                        legend(ev(indEvLegend), legendLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                else
                    channels = arrayfun(@(x) x.ChannelTags, self, 'UniformOutput',0);
                    [channels, order] = unique([channels{:}]);
                    [~,order] = sort(order);
                    channels = channels(order);
                    
                    [nH, nV] = panam_subplotDimensions(numel(channels));
                    count = 0;
                    % plot signals
                    for i = 1:numel(channels)
                        % first : get indices of signals
                        indSignals{i} = [];
                        for j = 1:numel(self)
                            indCh = find(strcmp(self(j).ChannelTags, channels{i}));
                            if ~isempty(indCh)
                                indSignals{i}(end+1) = j;
                            end
                        end
                        
                        hTemp = subplot(nH, nV, i);
                        pos = get(hTemp, 'Position');
                        delete(hTemp);
                        yInterval = pos(4) / numel(indSignals{i});
                        xmin = min(arrayfun(@(x) self(x).Time(1), indSignals{i}));
                        xmax = max(arrayfun(@(x) self(x).Time(end), indSignals{i}));
                        
                        for j = indSignals{i}
                            indCh = find(strcmp(self(j).ChannelTags, channels{i}));
                            h(count+1) = axes('Position', [pos(1) pos(2)+(numel(indSignals{i})-j)*yInterval pos(3) yInterval]);
                            hold on
                            plot(self(j).Time, self(j).Data(:,indCh));
                            ymin = min(self(j).Data(:,indCh));
                            ymax = max(self(j).Data(:,indCh));
                            delta = ymax - ymin;
                            ymin = ymin - 0.1*delta;
                            ymax = ymax + 0.1*delta;
                            axis([xmin xmax ymin ymax]);
                            a = axis;
                            ytick = mean(a(3:4)); % reverse
                            ytickLabel = {['Signal ' num2str(j)]};
                            set(gca, 'Ticklength', [0.002 0.005]);
                            set(gca, 'YTick', ytick);
                            set(gca, 'YTickLabel', ytickLabel);
                            % increment count
                            count = count + 1;
                        end
                        xlabel(h(count+1-numel(self(i).ChannelTags)),'Time');
                        title(h(count),title(channels{i}));
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        tmp = arrayfun(@(x) {x.Events.EventName}, self, 'UniformOutput',0);
                        eventNames = unique([tmp{:}]);
                        evColorMap = option.eventColormap;
                        eval(['evColor = ' evColorMap '(numel(eventNames));']);
                        evColor = num2cell(evColor,2);
                        eventCount = zeros(1,numel(eventNames)); % for legend
                        ev = [];
                        indEvLegend = []; % indices of ev handle-struct that will go into legend
                        legendLabels = {}; % associated legend entries
                        countEv = 0;
                        for i = 1:numel(channels)
                            for j = indSignals{i}
                                for k = 1:numel(self(j).Events)
                                    ind = find(strcmp(self(j).Events(k).EventName, eventNames));
                                    t1 = self(j).Events(k).Time;
                                    t2 = t1 + self(j).Events(k).Duration;
                                    a = axis(h(countEv+1));
                                    minEv = a(3);
                                    maxEv = a(4);
                                    if t2 == t1 % Duration = 0
                                        ev(end+1) = plot(h(countEv+1),[t1,t2], [minEv maxEv], 'color', evColor{ind},'Tag',self(j).Events(k).EventName, 'LineWidth',2);
                                    else
                                        ev(end+1) = fill(h(countEv+1),[t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],evColor{ind},'EdgeColor', evColor{ind}, 'Tag',self(j).Events(k).EventName, 'FaceAlpha', 0.2);
                                    end
                                    if eventCount(ind) == 0
                                        indEvLegend(end+1) = numel(ev); % index of considered ev-handle
                                        legendLabels(end+1) = {self(j).Events(k).EventName};
                                        eventCount(ind) = 1;
                                    end
                                end
                                countEv = countEv + 1;
                            end
                        end
                        legend(ev(indEvLegend), legendLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                end
                
                
                
            case 'grid'
                
            case 'superimpose'
                
            case 'avg'
                
            case 'confint'
               
        
                
        end
        
        
        
        
        
        
    case 'superimpose'
        switch option.signals
            case 'list'
                
            case 'grid'
                
            case 'superimpose'
                
            case 'avg'
                
            case 'confint'
                
        end
end
end

function [hOut, e, l] = plot_axes(hIn, x, y, events, legend, option)

axes(hIn);

% interval between plots
if numel(y) > 1
    interval = 1.5*max(cellfun(@(x) max(abs(x(:))), y));
end

% plot
for i = 1:numel(y)
    if size(x{i},1) > 1
        for j = 1:size(y{i},1)
            plot(x{i}(j,:),y{i}(j,:) - (i-1)  *interval);
        end
    else
        for j = 1:size(y{i},1)
            plot(x{i}(1,:),y{i}(j,:) - (i-1)  *interval);
        end
    end
end

% events
if iscell(events) % 1 event for each plot)
    
else % straightly events structure : same events for all plots of the gca
    
end





end



