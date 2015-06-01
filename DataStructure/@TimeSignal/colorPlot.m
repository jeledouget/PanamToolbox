% COLORPLOT
% plot the 'TimeSignal' elements as columns of a colorplot (data vs.
% time bins). Each element must have the same Time property
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


function h = colorPlot(self, commonOptions, specificOptions, varargin)

% defaults
if nargin < 3 || isempty(specificOptions)
    specificOptions = {};
end
if nargin < 2 || isempty(commonOptions)
    commonOptions = {};
end
if nargin > 1 && ~iscell(commonOptions)
    commonOptions = [commonOptions, specificOptions, varargin];
    specificOptions = {};
end

% check input
if ~all(arrayfun(@isNumTime, self)) || ~any(arrayfun(@isNumTime, self))
    error('Time property of the elements of the TimeSignal must be all numeric or all discrete');
end

% make self a column
self = self(:);

% check that Time property is the same for each element of self
if numel(self) > 1 && ~isequal(self.Time) % unequal Times
    lengths = arrayfun(@(x) length(x.Time), self);
    if any(lengths(2:end) - lengths(1:end-1)) % lengths of Time differ among elements of self
        error('Time properties are not of the same length : colorPlot cannot be applied');
    elseif self(1).isNumTime
        averageTime = mean(reshape([self.Time],[],numel(self)),2);
        for ii = 1:numel(self)
            orderTime{ii} = arrayfun(@(x) panam_closest(averageTime, x), self(ii).Time);
        end
        if isequal(orderTime{:}, 1:lengths(1)) % just a warning
            warning('times are not exactly the same in all elements of the TimeSignal');
        else
            error('Times should be the same so that mutiple-element TimeSignal object can be color-plotted');
        end
    else % discrete Time
        error('Times should have the same name so that mutiple-element TimeSignal object can ba color-plotted');
    end
elseif self(1).isNumTime
    averageTime = mean(reshape([self.Time],[],numel(self)),2);
end

% several channels : average or superimpose ?
handleChannels = 'average'; % default : average channels
hc = find(strcmpi(commonOptions,'handlechannels'));
if ~isempty(hc)
    if find(strcmpi(commonOptions{hc+1}, {'average', 'avg'}))
        handleChannels = 'average';
    elseif find(strcmpi(commonOptions{hc+1}, {'superimpose', 'stack'}))
        handleChannels = 'superimpose';
    else
        error('handlechannels options must be ''average'' or ''superimpose''');
    end
    commonOptions(hc:hc+1) = [];
end

% common options for Events
isEvents = 1; % default : show Events
isAvgEvents = 1; % default : average the events (one value per Time tag only)
evType = find(strcmpi(commonOptions,'events')); % 'avg' (average events), 'all' (show all events, not averaged), ou 'no' (hide events)
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

% specific options and colorbars for Events
if isEvents
    allEvents = [self.Events];
    if isAvgEvents
        allEvents = allEvents.avgEvents;
    else
        allEvents = allEvents.unifyEvents;
    end
    nEvents = length(allEvents);
    argEvSpecific = {}; % init
    % colormap for Events
    cm = find(strcmpi(argEvCommon,'colormap'));
    if ~isempty(cm)
        cmap_ev = argEvCommon{cm+1};
        argEvCommon(cm:cm+1) = [];
        eval(['cmap_ev = ' cmap_ev '(nEvents);']);
        cmap_ev = mat2cell(cmap_ev, ones(1,nEvents),3);
    else
        cmap_ev = lines(nEvents);
        cmap_ev = mat2cell(cmap_ev, ones(1,nEvents),3);
    end
    argEvSpecific{end+1} = 'color';
    argEvSpecific{end+1} = cmap_ev;
    % other options
    evOptions = find(strcmpi(specificOptions,'evOptions'));
    if ~isempty(evOptions)
        argEvSpecific = [argEvSpecific specificOptions{evOptions+1}];
        specificOptions(evOptions:evOptions+1) = [];
    end
end

% create data
switch handleChannels
    case 'average'
        for ii = 1:numel(self)
            self(ii) = self(ii).avgChannel;
        end
    case 'superimpose'
        % do nothing
end
data = [];
for ii = 1:numel(self)
    data = cat(2, data, self(ii).Data);
end
data = data';

% smooth data with gaussian filter
sm = find(strcmpi(commonOptions,'smooth'));
if ~isempty(sm)
    nPointsSmoothHor = commonOptions{sm+1}(1);
    nPointsSmoothVert = commonOptions{sm+1}(2);
    try 
        stdDevSmoothHor = commonOptions{sm+1}(3);
    catch
        stdDevSmoothHor = nPointsSmoothHor;
    end
    try
        stdDevSmoothVert = commonOptions{sm+1}(4);
    catch
        stdDevSmoothVert = nPointsSmoothVert;
    end
else
    nPointsSmoothHor = 1;
    nPointsSmoothVert = 1;
    stdDevSmoothHor = 1;
    stdDevSmoothVert = 1;
end
gaussFilter = customgauss([nPointsSmoothVert nPointsSmoothHor], stdDevSmoothVert, stdDevSmoothHor,0,0,1,[0 0]);
ratio = sum(sum(gaussFilter));
data = conv2(data, gaussFilter, 'same') / ratio;


% plot
h = gca; 
hold on
set(gca,'YDir','normal');
if self(1).isNumTime
    imagesc(averageTime,[],data);
else
    imagesc(1:size(data,1),[],data);
end
axis tight

% plot Events
legendTmp = {};
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

set(gca,'YTick',[]);
xlabel('Time')
legend(legendTmp)
legend hide
hold off

end