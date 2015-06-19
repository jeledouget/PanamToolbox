% SUBPLOTS
% plot the 'TimeSignal' as data vs. time bins, one subplot per channel
% valid only if number of dimensions <= 2 in Data property
% INPUTS :
    % commonOptions : cell of key-values pairs for plot properties that will
    % be shared by plots of all channels
    % specificOptions : cell of key-values pairs for plot properties that
    % will are specific to each channels ; each values of key-value pair
    % must be cell of length nChannels
% OUTPUTS :
% h : handle to the axes of the plot


function h = subplots(self, commonOptions, specificOptions, varargin)


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
nSignals = numel(self);

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

% channels
nChannels = arrayfun(@(x) length(x.ChannelTags), self);
if length(unique(nChannels)) == 1 % channel length always the same
    nChannels = max(nChannels);
    if numel(self) < 2 || isequal(self.ChannelTags) % are ChannelTags the same for all elements of self ?
        identicChannels = 1;
    else
        warning('channels do not have the same names among different elements of the TimeSignal object');
        identicChannels = 0;
    end
else
    error('subplots method cannot be applied if the number of channels differ between elements of the TimeSignal object');
end

% colormap for channels
cm = find(strcmpi(commonOptions,'colormap'));
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
        eval(['cmap = ' cmap '(nSignals + nEvents);']);
    else
        eval(['cmap = cat(1,' cmap '(nSignals), lines(nEvents));']);
    end
    cmap = mat2cell(cmap, ones(1,nSignals + nEvents),3);
else
    eval(['cmap = ' cmap '(nSignals);']);
    cmap = mat2cell(cmap, ones(1,nSignals),3);
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
        cmap_ev = cmap(nSignals+1:end);
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
figure;
[horDim, vertDim] = panam_subplotDimensions(nChannels);
for ii = 1:nChannels
    legendTmp = {};
    for kk = 1:numel(self)
        specificOptions_current = specificOptions;
        for jj = 2:2:length(specificOptions)
            specificOptions_current{jj} = specificOptions{jj}{ii};
        end
        specificOptions_current = [{'color', cmap{kk}} specificOptions_current];
        options = [commonOptions, specificOptions_current];
        h(ii) = subplot(horDim, vertDim, ii);
        hold on; % init legend
        if self(kk).isNumTime % Time property is a numeric vector
            plot(self(kk).Time, self(kk).Data(:,ii), options{:});
        else
            plot(self(kk).Data(:,ii), options{:});
            set(gca,'XTick',1:length(self(kk).Time), 'XTickLabel', self(kk).Time);
            a = axis;
            axis([a(1)-1 a(2)+1 a(3) a(4)]);
        end
        if identicChannels
            legendTmp = [legendTmp, ['signal ' num2str(kk)]];
        else
            legendTmp = [legendTmp, ['signal ' num2str(kk) ' ' self(kk).ChannelTags{ii}]];
        end
    end
    
    % plot events
    if isEvents % draw lines for Events
        if self(1).isNumTime
            a  = axis;
            for jj = 1:length(allEvents)
                argEvSpecific_current = argEvSpecific;
                for kk = 2:2:length(argEvSpecific)
                    argEvSpecific_current{kk} = argEvSpecific{kk}{jj};
                end
                for kk = 1:length(allEvents(jj).Time)
                    t = self(1).Events(jj).Time(kk);
                    plot([t t], [a(3) a(4)], argEvCommon{:}, argEvSpecific_current{:});
                    legendTmp = [legendTmp allEvents(jj).EventName];
                end
            end
        else
            warning('impossible to draw Events when Time is not numeric');
        end
    end
    
    xlabel('Time')
    legend(h(ii), legendTmp)
    legend hide
    if identicChannels
        title(self(1).ChannelTags{ii})
    else
        title(['channel ' num2str(ii)])
    end
end


end

