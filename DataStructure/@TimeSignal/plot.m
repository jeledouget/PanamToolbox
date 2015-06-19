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


function h = plot(self, commonOptions, specificOptions, varargin)

% TODO : check inputs
if ~all(arrayfun(@isNumTime, self)) || ~any(arrayfun(@isNumTime, self))
    error('Time property of the elements of the TimeSignal must be all numeric or all discrete');
end
if nargin > 1 && ~iscell(commonOptions)
    commonOptions = [commonOptions, specificOptions, varargin];
    specificOptions = {};
end

% make self a column
self = self(:);

% default
if nargin < 3 || isempty(specificOptions)
    specificOptions = {};
end
if nargin < 2 || isempty(commonOptions)
    commonOptions = {};
end

% common options for Events
isEvents = 1; % default : show Events
isAvgEvents = 1; % default : average the events (one value per Freq tag only)
evType = find(strcmpi(commonOptions,'events')); % 'avg' (average  events), 'all' (show all events, not averaged), ou 'no' (hide events)
if ~isempty(evType)
        if strcmpi(commonOptions{evType+1}, 'no')
            isEvents = 0;
        elseif strcmpi(commonOptions{evType+1}, 'all')
            isAvgEvents = 0;
        elseif strcmpi(commonOptions{evType+1}, 'avg')
            % do nothing
        else
            warning('after ''events'' option, parameter should be ''all'', ''avg'' or ''no'' ; here considered ''avg'' by default');
        end
        commonOptions(evType:evType+1) = [];
end
evOptions = find(strcmpi(commonOptions,'evOptions'));
argEvCommon = {'LineWidth',2}; % default
if ~isempty(evOptions)
    argEvCommon = [argEvCommon commonOptions{evOptions+1}];
    commonOptions(evOptions:evOptions+1) = [];
end

% colormap for channels
cm = find(strcmpi(commonOptions,'colormap'));
nChannels = arrayfun(@(x) length(x.ChannelTags), self);
nChannelsMax = max(nChannels);
if ~isempty(cm)
    cmap = commonOptions{cm+1};
    commonOptions(cm:cm+1) = [];
else
    cmap = 'lines'; % default colormap
end

allEvents = [self.Events];
if isempty(allEvents), isEvents = 0;end
if isEvents
    if isAvgEvents
        allEvents = allEvents.avgEvents;
    else
        allEvents = allEvents.unifyEvents;
    end
    nEvents = length(allEvents);
    if strcmpi(cmap, 'lines')
        eval(['cmap = ' cmap '(nChannelsMax + nEvents);']);
    else
        eval(['cmap = cat(1,' cmap '(nChannelsMax), lines(nEvents));']);
    end
    cmap = mat2cell(cmap, ones(1,nChannelsMax + nEvents),3);
else
    eval(['cmap = ' cmap '(nChannelsMax);']);
    cmap = mat2cell(cmap, ones(1,nChannelsMax),3);
end
    
% specific options and colorbars for Events
if isEvents
    argEvSpecific = {}; % init
    % colormap for Events
    cm = find(strcmpi(argEvCommon,'colormap'));
    if ~isempty(cm)
        cmap_ev = argEvCommon{cm+1};
        argEvCommon(cm:cm+1) = [];
        eval(['cmap_ev = ' cmap_ev '(nEvents);']);
        cmap_ev = mat2cell(cmap_ev, ones(1,nEvents),3);
    else
        cmap_ev = cmap(nChannelsMax+1:end);
    end
    argEvSpecific{end+1} = 'color';
    argEvSpecific{end+1} = cmap_ev;
    % other options
    fm = find(strcmpi(specificOptions,'events'));
    if ~isempty(fm)
        argEvSpecific = [argEvSpecific specificOptions{fm+1}];
        specificOptions(fm:fm+1) = [];
    end
end

% plot
h = gca; 
hold on
legendTmp = {};
for kk = 1:numel(self)
    specificOptions_element = [{'color', cmap(1:nChannels(kk))} specificOptions];
    for ii = 1:nChannels(kk)
        specificOptions_current = specificOptions_element;
        for jj = 2:2:length(specificOptions_element)
            specificOptions_current{jj} = specificOptions_element{jj}{ii};
        end
        options = [commonOptions, specificOptions_current];
        if self(kk).isNumTime % numeric time vector
            plot(self(kk).Time, self(kk).Data(:,ii), options{:});
        else
            plot(self(kk).Data(:,ii), options{:});
        end
        legendTmp = [legendTmp, self(kk).ChannelTags{ii}];
    end
end

% plot Events
if isEvents % draw lines for Time
    if self(1).isNumTime
        a  = axis;
        for ii = 1:length(allEvents)
            argEvSpecific_current = argEvSpecific;
            for jj = 2:2:length(argEvSpecific)
                argEvSpecific_current{jj} = argEvSpecific{jj}{ii};
            end
            for kk = 1:length(allEvents(ii).Time)
                t = allEvents(ii).Time(kk);
                plot([t t], [a(3) a(4)], argEvCommon{:}, argEvSpecific_current{:});
                legendTmp = [legendTmp allEvents(ii).EventName];
            end
        end
    else
        warning('impossible to draw Events when Time is not numeric');
    end
end

if ~self(1).isNumTime
    times = {self.Time};
    if ~isequal(times{:})
        warning('times differ between elements of the TimeSignal');
    else
        set(gca,'XTick',1:length(self.Time), 'XTickLabel', self.Time);
    end
    a = axis;
    axis([a(1)-1 a(2)+1 a(3) a(4)]);
end

xlabel('Time')
legend(legendTmp)
legend hide
hold off

end

