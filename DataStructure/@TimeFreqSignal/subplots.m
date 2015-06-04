% SUBPLOTS
% plot the average of 'TimeFreqSignal' elements (freq vs.
% time bins). One subplot per channel. Each element must have the same Time property
% valid only if number of dimensions <= 2 in Data property
% WARNING : if several channels are present, they will be averaged. default : averaged
% INPUTS :
    % commonOptions : cell of key-values pairs for plot properties that will
    % be shared by plots of all channels
    % specificOptions : cell of key-values pairs for plot properties that
    % will are specific to each channels ; each values of key-value pair
    % must be cell of length nChannels
% OUTPUTS :
    % h : handle to the axes of the plot


function h = subplots(self, commonOptions, specificOptions, varargin)

% average self
if numel(self) > 1
    self = self.avgElements;
end

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
if ~(all(arrayfun(@isNumTime, self)) || ~any(arrayfun(@isNumTime, self)))
    error('Time property of the elements of the TimeFreqSignal must be all numeric or all discrete');
end
if ~(all(arrayfun(@isNumFreq, self)) || ~any(arrayfun(@isNumFreq, self)))
    error('Freq property of the elements of the TimeFreqSignal must be all numeric or all discrete');
end

% channels
channels = self(1).ChannelTags;
nChannels = length(channels);

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

% common options for FreqMarkers
isMarkers = 1; % default : show Markers
isAvgMarkers = 1; % default : average the freq markers (one value per Freq tag only)
fmType = find(strcmpi(commonOptions,'freqmarkers')); % 'avg' (average markers), 'all' (show all markers, not averaged), ou 'no' (hide markers)
if ~isempty(fmType)
        if strcmpi(commonOptions{fmType+1}, 'no')
            isMarkers = 0;
        elseif strcmpi(commonOptions{fmType+1}, 'all')
            isAvgMarkers = 0;
        elseif strcmpi(commonOptions{fmType+1}, 'avg')
            % do nothing
        else
            warning('after ''freqmarkers'' option, parameter should be ''all'', ''avg'' or ''no'' ; here considered ''avg'' by default');
        end
        commonOptions(fmType:fmType+1) = [];
end
fmOptions = find(strcmpi(commonOptions,'fmOptions'));
argFmCommon = {'LineWidth',2}; % default
if ~isempty(fmOptions)
    argFmCommon = [argFmCommon commonOptions{fmOptions+1}];
    commonOptions(fmOptions:fmOptions+1) = [];
end

% specific options and colorbars for freqMarkers
if isMarkers
    allMarkers = [self.FreqMarkers];
    if isAvgMarkers
        allMarkers = allMarkers.avgMarkers;
    else
        allMarkers = allMarkers.unifyMarkers;
    end
    nMarkers = length(allMarkers);
    argFmSpecific = {}; % init
    % colormap for FreqMarkers
    cm = find(strcmpi(argFmCommon,'colormap'));
    if ~isempty(cm)
        cmap_fm = argFmCommon{cm+1};
        argFmCommon(cm:cm+1) = [];
        eval(['cmap_fm = ' cmap_fm '(nMarkers);']);
        cmap_fm = mat2cell(cmap_fm, ones(1,nMarkers),3);
    else
        cmap_fm = lines(nMarkers);
        cmap_fm = mat2cell(cmap_fm, ones(1,nMarkers),3);
    end
    argFmSpecific{end+1} = 'color';
    argFmSpecific{end+1} = cmap_fm;
    % other options
    fmOptions = find(strcmpi(specificOptions,'fmOptions'));
    if ~isempty(fmOptions)
        argFmSpecific = [argFmSpecific specificOptions{fmOptions+1}];
        specificOptions(fmOptions:fmOptions+1) = [];
    end
end

% data to plot :
data = permute(self.Data,[2 1 3]); % new order : freq x time x channels

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
for ii = 1:size(data,3)
    data(:,:,ii) = conv2(data(:,:,ii), gaussFilter, 'same') / ratio;
end

% plot
figure;
[horDim, vertDim] = panam_subplotDimensions(nChannels);
for ii = 1:nChannels
    legendTmp = {};
    h(ii) = subplot(horDim, vertDim, ii);
    hold on; % init legend
    if self(1).isNumTime
        if self.isNumFreq
            imagesc(self.Time,self.Freq,data(:,:,ii));
        else
            imagesc(self.Time,1:size(data,1),data(:,:,ii));
        end
    else
        if self.isNumFreq
            imagesc(1:size(data,2),self.Freq,data(:,:,ii));
        else
            imagesc(1:size(data,2),1:size(data,1),data(:,:,ii));
        end
    end
    axis tight
    
    % plot freqmarkers
    if isMarkers % draw lines for FreqMarkers
        if self(1).isNumFreq
            a  = axis;
            for jj = 1:length(allMarkers)
                argFmSpecific_current = argFmSpecific;
                for kk = 2:2:length(argFmSpecific)
                    argFmSpecific_current{kk} = argFmSpecific{kk}{jj};
                end
                for kk = 1:length(allMarkers(jj).Freq)
                    t = self(1).FreqMarkers(jj).Freq(kk);
                    plot([a(1) a(2)],[t t], argFmCommon{:}, argFmSpecific_current{:});
                    legendTmp = [legendTmp allMarkers(jj).MarkerName];
                end
            end
        else
            warning('impossible to draw FreqMarkers when Freq is not numeric');
        end
    end
    
    if ~self(1).isNumFreq
        set(gca,'YTick',1:length(self.Freq), 'YTickLabel', self.Freq);
%         a = axis;
%         axis([a(1)-1 a(2)+1 a(3) a(4)]);
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
    
    if ~self(1).isNumTime
        set(gca,'XTick',1:length(self.Time), 'XTickLabel', self.Time);
%         a = axis;
%         axis([a(1)-1 a(2)+1 a(3) a(4)]);
    end
    
    title(channels{ii})
    xlabel('Time')
    ylabel('Frequency')
    legend(legendTmp)
    legend hide
    hold off
    
end

end