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
defaultOption.channels = 'avg';
defaultOption.signals = 'superimpose';%'superimpose';
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

% init events
if strcmpi(option.events, 'yes')
    [eventNames, eventColors, legStatus, legLabels, legHandles] =  init_events(self, option);
end


% plot
switch option.channels
    case 'list'
        switch option.signals
            case 'list'
                if option.uniqueAxes
                    y = arrayfun(@(x) arrayfun(@(i) {x.Data(:,i)'}, 1:size(x.Data,2), 'UniformOutput',0), self, 'UniformOutput',0);
                    y = [y{:}]';
                    x = arrayfun(@(x) arrayfun(@(i) {x.Time}, 1:size(x.Data,2), 'UniformOutput',0), self, 'UniformOutput',0);
                    x = [x{:}]';
                    h = axes();
                    xlabel('Time');
                    [h, interval, ytick] = plot_data(h, x, y, option);
                    ytickLabel = {};
                    for i = 1:numel(self)
                        for j = 1:numel(self(i).ChannelTags)
                            ytickLabel(end+1) = {['Signal' num2str(i) ' - Channel ' self(i).ChannelTags{j}]};
                        end
                    end
                    ytickLabel = ytickLabel(end:-1:1);
                    if strcmpi(option.events, 'yes')
                        events = arrayfun(@(x) arrayfun(@(i) x.Events.sortByTime, 1:size(x.Data,2), 'UniformOutput',0), self, 'UniformOutput',0);
                        events = [events{:}]';
                        [h, legStatus, legLabels, legHandles] = plot_events(h, y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                    end
                    % axes properties
                    set(gca, 'Ticklength', [0.002 0.005]);
                    set(gca, 'YTick', ytick);
                    set(gca, 'YTickLabel', ytickLabel);
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                else
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
                            x{1}{1} = self(i).Time;
                            y{1}{1} = self(i).Data(:,j)';
                            h(count+1) = axes('Position', [0.1 0.05+count*interval 0.8 interval]);
                            [h(count+1), ~, ytick] = plot_data(h(count+1), x, y, option);
                            if strcmpi(option.events, 'yes')
                                events = self(i).Events.sortByTime;
                                [h(count+1), legStatus, legLabels, legHandles] = plot_events(h(count+1), y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                            end
                            ytickLabel = {['Signal' num2str(i) ' - Channel ' self(i).ChannelTags{j}]};
                            set(gca, 'Ticklength', [0.002 0.005]);
                            set(gca, 'YTick', ytick);
                            set(gca, 'YTickLabel', ytickLabel);
                            % increment count
                            count = count + 1;
                        end
                    end
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                end
            case 'grid'
                if option.uniqueAxes
                    nPlots = numel(self);
                    [nH, nV] = panam_subplotDimensions(nPlots);
                    % plot signals
                    for i = 1:numel(self)
                        h(i) = subplot(nH, nV, i);
                        y = arrayfun(@(ind) {self(i).Data(:,ind)'}, 1:size(self(i).Data,2), 'UniformOutput',0);
                        x = arrayfun(@(ind) {self(i).Time}, 1:size(self(i).Data,2));
                        ytickLabel = self(i).ChannelTags;
                        [h(i), interval, ytick] = plot_data(h(i), x, y, option);
                        % events
                        if strcmpi(option.events, 'yes')
                            events = self(i).Events.sortByTime;
                            [h(i) , legStatus, legLabels, legHandles] = plot_events(h(i) , y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                        end
                        xlabel('Time');
                        title(['Signal ' num2str(i)]);
                        ytickLabel = ytickLabel(end:-1:1);
                        set(gca, 'Ticklength', [0.002 0.005]);
                        set(gca, 'YTick', ytick);
                        set(gca, 'YTickLabel', ytickLabel);
                    end
                    % axes properties
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                else
                    [nH, nV] = panam_subplotDimensions(numel(self));
                    count = 0;
                    % plot signals
                    for i = 1:numel(self)
                        hTemp = subplot(nH, nV, i);
                        pos = get(hTemp, 'Position');
                        delete(hTemp);
                        interval = pos(4) / numel(self(i).ChannelTags);
                        x{1}{1} = self(i).Time;
                        for j = numel(self(i).ChannelTags):-1:1
                            y{1}{1} = self(i).Data(:,j)';
                            h(count+1) = axes('Position', [pos(1) pos(2)+(numel(self(i).ChannelTags)-j)*interval pos(3) interval]);
                            [h(count+1), ~, ytick] = plot_data(h(count+1), x, y, option);
                            if strcmpi(option.events, 'yes')
                                events = self(i).Events.sortByTime;
                                [h(count+1), legStatus, legLabels, legHandles] = plot_events(h(count+1), y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                            end
                            ytickLabel = self(i).ChannelTags(j);
                            set(gca, 'Ticklength', [0.002 0.005]);
                            set(gca, 'YTick', ytick);
                            set(gca, 'YTickLabel', ytickLabel);
                        end
                        % axes
                        title(['Signal' num2str(i)]);
                        % increment count
                        count = count + 1;
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                    % axes properties
                end
            case 'superimpose'
                channels = arrayfun(@(x) x.ChannelTags, self, 'UniformOutput',0);
                [channels, order] = unique([channels{:}]);
                [~,order] = sort(order);
                channels = channels(order);
                colorMap = option.colormap;
                eval(['plotColors = ' colorMap '(numel(self));']);
                plotColors = num2cell(plotColors,2);
                % plot
                if option.uniqueAxes
                    for i = 1:numel(channels)
                        for j = 1:numel(self)
                            indChan = find(strcmpi(self(j).ChannelTags, channels{i}));
                            if ~isempty(indChan)
                                y{i}{j} = self(j).Data(:,indChan)';
                                x{i}{j} = self(j).Time;
                            end
                        end
                    end
                    h = axes();
                    xlabel('Time');
                    [h, interval, ytick] = plot_data(h, x, y, option);
                    ytickLabel = {};
                    for i = 1:numel(channels)
                        ytickLabel(end+1) = channels(i);
                    end
                    ytickLabel = ytickLabel(end:-1:1);
                    if strcmpi(option.events, 'yes')
                        events = self.avgElements.Events.sortByTime;
                        [h, legStatus, legLabels, legHandles] = plot_events(h, y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                    end
                    set(gca, 'Ticklength', [0.002 0.005]);
                    set(gca, 'YTick', ytick);
                    set(gca, 'YTickLabel', ytickLabel);
                    % events
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                else
                    % axes properties
                    nAxes = numel(channels);
                    interval = 0.9 / nAxes;
                    % plot signals
                    count = 0;
                    if strcmpi(option.events, 'yes')
                        events = self.avgElements.Events.sortByTime;
                    end
                    for i = numel(channels):-1:1
                        for j = 1:numel(self)
                            indChan = find(strcmpi(self(j).ChannelTags, channels{i}));
                            if ~isempty(indChan)
                                y{1}{j} = self(j).Data(:,indChan)';
                                x{1}{j} = self(j).Time;
                            end
                        end
                        h(count+1) = axes('Position', [0.1 0.05+count*interval 0.8 interval]);
                        [h(count+1), ~, ytick] = plot_data(h(count+1), x, y, option);
                        ytickLabel = channels(i);
                        if strcmpi(option.events, 'yes')
                            [h(count+1), legStatus, legLabels, legHandles] = plot_events(h(count+1), y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                        end
                        set(gca, 'Ticklength', [0.002 0.005]);
                        set(gca, 'YTick', ytick);
                        set(gca, 'YTickLabel', ytickLabel);
                        count = count + 1;
                    end
                    % axes properties
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                    xlabel(h(1), 'Time');
                end
            case 'avg'
                if option.newFigure
                    close gcf;% avoid double opening of figure
                end
                defaultOption.avgOptions = {}; % use default avgOptions
                option = setstructfields(defaultOption, varargin);
                try option.avgOptions = panam_args2struct(option.avgOptions);end;
                self = self.avgElements(option.avgOptions);
                option.signals = 'list';
                [h, ev] = self.plot(option);
                channels = arrayfun(@(x) x.ChannelTags, self, 'UniformOutput',0);
                [channels, order] = unique([channels{:}]);
                [~,order] = sort(order);
                channels = channels(order);
                if option.uniqueAxes
                    ytickLabel = channels(end:-1:1);
                    set(h, 'YTickLabel', ytickLabel);
                else
                    for i = 1:numel(h)
                        set(h(i), 'YTickLabel', channels(end+1-i));
                    end
                end
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
                    y = arrayfun(@(j) arrayfun(@(i) self.Data(:,i,j)', 1:size(self.Data,2), 'UniformOutput',0), 1:size(self.Data,3), 'UniformOutput',0);
                    x = {self.Time};
                    interval = 1.5*max(arrayfun(@(x) max(abs(x.Data(:))), self));
                    h = axes();
                    xlabel('Time');
                    [h, ~, ytick] = plot_data(h, x, y, option);
                    % events
                    events = self.Events.sortByTime;
                    if strcmpi(option.events, 'yes')
                        [h, legStatus, legLabels, legHandles] = plot_events(h, y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                    end
                    % axes properties
                    set(gca, 'Ticklength', [0.002 0.005]);
                    set(gca, 'YTick', ytick);
                    ytickLabel = self.ChannelTags(end:-1:1);
                    set(h, 'YTickLabel', ytickLabel);
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                else % one axes for each plot
                    % axes properties
                    nAxes = numel(self.ChannelTags);
                    interval = 0.9 / nAxes;
                    if strcmpi(option.events, 'yes')
                        % events
                        events = self.Events.sortByTime;
                    end
                    for i = nAxes:-1:1
                        y = {arrayfun(@(j) self.Data(:,j,i)', 1:size(self.Data,2), 'UniformOutput',0)};
                        x = arrayfun(@(i) self.Time, 1:size(self.Data,3), 'UniformOutput',0);
                        h(i) = axes('Position', [0.1 0.05+(nAxes-i)*interval 0.8 interval]);
                        [h(i), ~, ytick] = plot_data(h(i), x, y, option);
                        if strcmpi(option.events, 'yes')
                            [h(i), legStatus, legLabels, legHandles] = plot_events(h(i), y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                        end
                        set(gca, 'Ticklength', [0.002 0.005]);
                        set(gca, 'YTick', ytick);
                        ytickLabel = self.ChannelTags(i);
                        set(h(i), 'YTickLabel', ytickLabel);
                    end
                    % axes properties
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                    xlabel(h(nAxes), 'Time');
                    
                end
        end
        
    case 'grid'
        % channels
        channels = arrayfun(@(x) x.ChannelTags, self, 'UniformOutput',0);
        [channels, order] = unique([channels{:}]);
        [~,order] = sort(order);
        channels = channels(order);
        colorMap = option.colormap;
        eval(['plotColors = ' colorMap '(numel(self));']);
        plotColors = num2cell(plotColors,2);
        % plot
        switch option.signals
            case 'list'
                if option.uniqueAxes
                    nPlots = numel(channels);
                    [nH, nV] = panam_subplotDimensions(nPlots);
                    % plot signals
                    for i = 1:nPlots
                        y = {};
                        x = {};
                        events = {};
                        ytickLabel = {};
                        h(i) = subplot(nH, nV, i);
                        for j = 1:numel(self)
                            ind = find(strcmpi(self(j).ChannelTags, channels{i}));
                            if ~isempty(ind)
                                y{end+1} = {self(j).Data(:,ind)'};
                                x{end+1} = self(j).Time;
                                events{end+1} = self(j).Events;
                                ytickLabel(end+1) = {['Signal ' num2str(j)]};
                            end
                        end
                        [h(i), interval, ytick] = plot_data(h(i), x, y, option);
                        % events
                        if strcmpi(option.events, 'yes')
                            events = self(i).Events.sortByTime;
                            [h(i) , legStatus, legLabels, legHandles] = plot_events(h(i) , y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                        end
                        xlabel('Time');
                        title(channels(i));
                        ytickLabel = ytickLabel(end:-1:1);
                        set(gca, 'Ticklength', [0.002 0.005]);
                        set(gca, 'YTick', ytick);
                        set(gca, 'YTickLabel', ytickLabel);
                    end
                    % axes properties
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                else
                    [nH, nV] = panam_subplotDimensions(numel(channels));
                    count = 0;
                    % plot signals
                    for i = 1:numel(channels)
                        hTemp = subplot(nH, nV, i);
                        pos = get(hTemp, 'Position');
                        delete(hTemp);
                        indSignals = arrayfun(@(s) strcmpi(s.ChannelTags, channels{i}), self, 'UniformOutput',0);
                        nPlots = sum(cell2mat(indSignals'));
                        interval = pos(4) / nPlots;
                        subcount = 0;
                        for j = 1:numel(self)
                            indChan = find(indSignals{j}, 1);
                            if ~isempty(indChan)
                                y{1} = {self(j).Data(:,indChan)'};
                                x{1} = self(j).Time;
                                h(count+1) = axes('Position', [pos(1) pos(2)+subcount*interval pos(3) interval]);
                                [h(count+1), ~, ytick] = plot_data(h(count+1), x, y, option);
                                if strcmpi(option.events, 'yes')
                                    events = self(j).Events.sortByTime;
                                    [h(count+1), legStatus, legLabels, legHandles] = plot_events(h(count+1), y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                                end
                                ytickLabel = ['Signal ' num2str(j)];
                                set(gca, 'Ticklength', [0.002 0.005]);
                                set(gca, 'YTick', ytick);
                                set(gca, 'YTickLabel', ytickLabel);
                                subcount = subcount + 1;
                            end
                            % increment count
                            count = count + 1;
                        end
                        title(channels{i});
                        xlabel(h(count + 1 - subcount), 'Time');
                    end
                    % events
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                    % axes properties
                end
            case 'grid'
                nPlots = sum(arrayfun(@(x) numel(x.ChannelTags),self));
                [nH, nV] = panam_subplotDimensions(nPlots);
                % plot signals
                count = 0;
                interval = 0;
                for i = 1:numel(self)
                    events = self(i).Events.sortByTime;
                    for j = 1:numel(self(i).ChannelTags)
                        y{1} = {self(i).Data(:,j)'};
                        x{1} = self(i).Time;
                        h(count+1) = subplot(nH, nV, count+1);
                        [h(count+1), ~, ~] = plot_data(h(count+1), x, y, option);
                        if strcmpi(option.events, 'yes')
                            [h(count+1), legStatus, legLabels, legHandles] = plot_events(h(count+1), y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                        end
                        xlabel('Time');
                        title(['Signal ' num2str(i) ' - ' self(i).ChannelTags{j}]);
                        set(gca, 'Ticklength', [0.002 0.005]);
                        count = count + 1;
                    end
                end
                % axes properties
                if strcmpi(option.events, 'yes')
                    legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                end
            case 'superimpose'
                nPlots = numel(channels);
                [nH, nV] = panam_subplotDimensions(nPlots);
                % plot signals
                interval = 0;
                if strcmpi(option.events, 'yes')
                    events = self.avgElements.Events.sortByTime;
                end
                for i = 1:numel(channels)
                    h(i) = subplot(nH, nV, i);
                    y{1} = {};
                    x{1} = {};
                    indSignals = arrayfun(@(s) strcmpi(s.ChannelTags, channels{i}), self, 'UniformOutput',0);
                    for j = 1:numel(self)
                        indChan = find(indSignals{j}, 1);
                        if ~isempty(indChan)
                            y{1}{end+1} = self(j).Data(:,indChan)';
                            x{1}{end+1} = self(j).Time;
                        end
                    end
                    [h(i), ~, ~] = plot_data(h(i), x, y, option);
                    if strcmpi(option.events, 'yes')
                        [h(i), legStatus, legLabels, legHandles] = plot_events(h(i), y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                    end
                    xlabel('Time');
                    title(channels{i});
                    set(gca, 'Ticklength', [0.002 0.005]);
                end
                % axes properties
                if strcmpi(option.events, 'yes')
                    legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                end
            case 'avg'
                if option.newFigure
                    close gcf;% avoid double opening of figure
                end
                defaultOption.avgOptions = {}; % use default avgOptions
                option = setstructfields(defaultOption, varargin);
                try option.avgOptions = panam_args2struct(option.avgOptions);end;
                self = self.avgElements(option.avgOptions);
                option.signals = 'list';
                [h, ev] = self.plot(option);
                for i = 1:numel(h)
                    set(h(i), 'YTickMode', 'auto', 'YTickLabelMode', 'auto')
                end
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
                % axes properties
                nAxes = numel(self.ChannelTags);
                [nH, nV] = panam_subplotDimensions(nAxes);
                interval = 0;
                if strcmpi(option.events, 'yes')
                    % events
                    events = self.Events.sortByTime;
                end
                for i = 1:nAxes
                    y = {arrayfun(@(j) self.Data(:,j,i)', 1:size(self.Data,2), 'UniformOutput',0)};
                    x = arrayfun(@(i) self.Time, 1:size(self.Data,3), 'UniformOutput',0);
                    h(i) = subplot(nH, nV, i);
                    h(i) = plot_data(h(i), x, y, option);
                    if strcmpi(option.events, 'yes')
                        [h(i), legStatus, legLabels, legHandles] = plot_events(h(i), y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                    end
                    set(gca, 'Ticklength', [0.002 0.005]);
                    title(self.ChannelTags{i});
                end
                % axes properties
                if strcmpi(option.events, 'yes')
                    legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                end
                for i = 1:numel(h)
                    set(h(i), 'YTickMode', 'auto', 'YTickLabelMode', 'auto')
                end
                xlabel(h(nAxes), 'Time');
        end
     
        
    case 'superimpose'
        switch option.signals
            case 'list'               
                if option.uniqueAxes
                    y = arrayfun(@(x) arrayfun(@(i) x.Data(:,i)', 1:size(x.Data,2), 'UniformOutput',0), self, 'UniformOutput',0);
                    x = arrayfun(@(x) x.Time, self, 'UniformOutput',0);
                    h = axes();
                    xlabel('Time');
                    [h, interval, ytick] = plot_data(h, x, y, option);
                    ytickLabel = {};
                    for i = 1:numel(self)
                            ytickLabel(end+1) = {['Signal' num2str(i)]};
                    end
                    ytickLabel = ytickLabel(end:-1:1);
                    if strcmpi(option.events, 'yes')
                        events = arrayfun(@(x) x.Events.sortByTime, self, 'UniformOutput',0);
                        [h, legStatus, legLabels, legHandles] = plot_events(h, y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                    end
                    % axes properties
                    set(gca, 'Ticklength', [0.002 0.005]);
                    set(gca, 'YTick', ytick);
                    set(gca, 'YTickLabel', ytickLabel);
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                else
                    % axes properties
                    nAxes = numel(self);
                    interval = 0.9 / nAxes;
                    % plot signals
                    count = 0;
                    for i = numel(self):-1:1
                        for j = 1:numel(self(i).ChannelTags)
                            x{1} = self(i).Time;
                            y{1}{j} = self(i).Data(:,j)';
                        end
                        h(count+1) = axes('Position', [0.1 0.05+count*interval 0.8 interval]);
                        [h(count+1), ~, ytick] = plot_data(h(count+1), x, y, option);
                        if strcmpi(option.events, 'yes')
                            events = self(i).Events.sortByTime;
                            [h(count+1), legStatus, legLabels, legHandles] = plot_events(h(count+1), y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                        end
                        ytickLabel = {['Signal ' num2str(i)]};
                        set(gca, 'Ticklength', [0.002 0.005]);
                        set(gca, 'YTick', ytick);
                        set(gca, 'YTickLabel', ytickLabel);
                        % increment count
                        count = count + 1;
                    end
                    if strcmpi(option.events, 'yes')
                        legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                    end
                end
            case 'grid'
                % axes properties
                nAxes = numel(self);
                [nH, nV] = panam_subplotDimensions(nAxes);
                interval = 0;
                % plot signals
                for i = 1:numel(self)
                    for j = 1:numel(self(i).ChannelTags)
                        x{1} = self(i).Time;
                        y{1}{j} = self(i).Data(:,j)';
                    end
                    h(i) = subplot(nH, nV, i);
                    h(i) = plot_data(h(i), x, y, option);
                    if strcmpi(option.events, 'yes')
                        events = self(i).Events.sortByTime;
                        [h(i), legStatus, legLabels, legHandles] = plot_events(h(i), y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                    end
                    title(['Signal ' num2str(i)]);
                    set(gca, 'Ticklength', [0.002 0.005]);
                end
                if strcmpi(option.events, 'yes')
                    legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                end
                for i = 1:numel(h)
                    set(h(i), 'YTickMode', 'auto', 'YTickLabelMode', 'auto')
                end
            case 'superimpose'
                % axes properties
                interval = 0;
                y{1} = {};
                x{1} = {};
                % plot signals
                for i = 1:numel(self)
                    for j = 1:numel(self(i).ChannelTags)
                        x{1}{end+1} = self(i).Time;
                        y{1}{end+1} = self(i).Data(:,j)';
                    end
                end
                h = axes();
                h = plot_data(h, x, y, option);
                if strcmpi(option.events, 'yes')
                    events = self.avgElements.Events.sortByTime;
                    [h, legStatus, legLabels, legHandles] = plot_events(h, y, interval, events, eventNames, eventColors, legStatus, legLabels, legHandles);
                end
                title('All Signals - All Channels');
                set(gca, 'Ticklength', [0.002 0.005]);
                if strcmpi(option.events, 'yes')
                    legend(legHandles, legLabels, 'Position', [0.94 0.85 0.03 0.1]);
                end
                for i = 1:numel(h)
                    set(h(i), 'YTickMode', 'auto', 'YTickLabelMode', 'auto')
                end
            case 'avg'
                if option.newFigure
                    close gcf;% avoid double opening of figure
                end
                defaultOption.avgOptions = {}; % use default avgOptions
                option = setstructfields(defaultOption, varargin);
                try option.avgOptions = panam_args2struct(option.avgOptions);end;
                self = self.avgElements(option.avgOptions);
                option.signals = 'list';
                [h, ev] = self.plot(option);
                set(h, 'YTickMode', 'auto', 'YTickLabelMode', 'auto');
                title('Avg Signals - All Channels');
                xlabel('Time');
        end
    case 'avg'
        if option.newFigure
            close gcf;% avoid double opening of figure
        end
        defaultOption.avgChannelOptions = {}; % use default avgOptions
        option = setstructfields(defaultOption, varargin);
        self = self.avgChannel(option.avgChannelOptions{:});
        option.channels = 'grid';
        [h, ev] = self.plot(option);
end

end



function [hOut, interval, ytick] = plot_data(hIn, x, y, option)

hOut = hIn;
axes(hOut);
hold on
ytick = [];
interval = 0; % default

% interval between plots
if numel(y) > 1 % several vertical curves
    interval = 1.5*max(cellfun(@(c1) max(cellfun(@(c2) max(abs(c2)), c1)),y));
end

% confint
if strcmp(option.signals,'confint') || strcmp(option.channels,'confint')
    for i = 1:numel(y)
        if numel(y{i}) == 2
            confplot(x{i}, y{i}{1} - (i-1) * interval, y{i}{2}); % symetric error
        else
            confplot(x{i}, y{i}{1} - (i-1) * interval, y{i}{2}, y{i}{3}); % lower and upper error
        end
        hold on
        meanTrace = nanmean(y{i}{1} - (i-1) * interval);
        ytick = [meanTrace , ytick];
    end
else
    % plot
    for i = 1:numel(y)
        meanTrace = 0;
        for j = 1:numel(y{i})
            
            tmpData  = y{i}{j} - (i-1) * interval;
            
            if iscell(x{i}) % time for each trace
                plot(x{i}{j},tmpData);
            else
                plot(x{i},tmpData);
            end
            meanTrace = meanTrace + nanmean(tmpData);
        end
        meanTrace = meanTrace / numel(y{i});
        ytick = [meanTrace , ytick];
    end
end

axis tight
a = axis;
if option.uniqueAxes
    axis([a(1:2) a(3)-0.02*abs(a(4)-a(3))  a(4)+0.02*abs(a(4)-a(3))]);
else
    axis([a(1:2) a(3)-0.05*abs(a(4)-a(3))  a(4)+0.05*abs(a(4)-a(3))]);
end

end


function [hOut, legStatusOut, legLabelsOut, legHandlesOut] = plot_events(hIn, y, interval, events, eventNames, eventColors, legStatusIn, legLabelsIn, legHandlesIn)

hOut = hIn;
axes(hOut);
hold on

legStatusOut = legStatusIn;
legLabelsOut = legLabelsIn;
legHandlesOut = legHandlesIn;

% events
if iscell(events) % 1 event for each data plot)
    for i = 1:size(y,1)
        for k = 1:numel(events{i})
            ind = find(strcmp(events{i}(k).EventName, eventNames));
            t1 = events{i}(k).Time;
            t2 = t1 + events{i}(k).Duration;
            minEv = nanmean(cat(2,y{i}{:})) - (i-1+0.5)* interval;
            maxEv = nanmean(cat(2,y{i}{:})) - (i-1-0.5)* interval;
            if t2 == t1 % Duration = 0
                ev = plot([t1,t2], [minEv maxEv], 'color', eventColors{ind},'Tag',events{i}(k).EventName, 'LineWidth',2);
            else
                ev = fill([t1, t1,t2, t2], [minEv, maxEv,maxEv, minEv],eventColors{ind},'EdgeColor', eventColors{ind}, 'Tag',events{i}(k).EventName, 'FaceAlpha', 0.2);
            end
            if legStatusOut(ind) == 0
                legHandlesOut(end+1) = ev;
                legLabelsOut(end+1) = {events{i}(k).EventName};
                legStatusOut(ind) = 1;
            end
        end
    end
else % straightly events structure : same events for all plots of the gca
    for k = 1:numel(events)
        ind = find(strcmp(events(k).EventName, eventNames));
        t1 = events(k).Time;
        t2 = t1 + events(k).Duration;
        a = axis(hOut);
        minEv = a(3);
        maxEv = a(4);
        if t2 == t1 % Duration = 0
            ev = plot([t1,t2], [minEv maxEv], 'color', eventColors{ind},'Tag',events(k).EventName, 'LineWidth',2);
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



