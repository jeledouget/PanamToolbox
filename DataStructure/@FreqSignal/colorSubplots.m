% COLORSUBPLOTS
% plot the 'FreqSignal' elements as columns of a colorplot (data vs.
% frequency bins). Each element must have the same Freq property
% valid only if number of dimensions <= 2 in Data property
% A subplot is drawn for each channel
% INPUTS :
% commonOptions : cell of key-values pairs for plot properties that will
% be shared by plots of all channels
% specificOptions : cell of key-values pairs for plot properties that
% will are specific to each channels ; each values of key-value pair
% must be cell of length nChannels
% OUTPUTS :
% h : handle to the axes of the plot


function h = colorSubplots(self, commonOptions, specificOptions, varargin)

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
if ~all(arrayfun(@isNumFreq, self)) || ~any(arrayfun(@isNumFreq, self))
    error('Freq property of the elements of the FreqSignal must be all numeric or all discrete');
end

% make self a column
self = self(:);

% check that Freq property is the same for each element of self
if numel(self) > 1 && ~isequal(self.Freq)
    lengths = arrayfun(@(x) length(x.Freq), self);
    if any(lengths(2:end) - lengths(1:end-1)) % lengths of Freq differ among elements of self
        error('Freq properties are not of the same length : colorPlot cannot be applied');
    elseif self(1).isNumFreq
        averageFreq = mean(reshape([self.Freq],[],numel(self)),2);
        for ii = 1:numel(self)
            orderFreq{ii} = arrayfun(@(x) panam_closest(averageFreq, x), self(ii).Freq);
        end
        if isequal(orderFreq{:}, 1:lengths(1))
            warning('frequencies are not exacatly the same in all elements of the FreqSignal');
        else
            error('Frequencies should be the same so that mutiple-element FreqSignal object can ba color-plotted');
        end
    else % discrete Frequencies
        error('Frequencies should have the same name so that mutiple-element FreqSignal object can ba color-plotted');
    end
elseif self(1).isNumFreq
    averageFreq = mean(reshape([self.Freq],[],numel(self)),2);
end

% check channels : they must be the same for all elements of self
% if not, at least the number of channels must be the same and a warning thrown
if isequal(self.ChannelTags) % same channels for all elements
    channels = self(1).ChannelTags;
else
    len = arrayfun(@(x) length(x.ChannelTags), tmp);
    if length(unique(len)) == 1 % all lengths are the same
        channels = arrayfun(@(x) ['chan' num2str(x)],1:len(1),'UniformOutput',0);
        warning('channels do not all have the same name ; plots are made in function of the order of the channels');
    else
        error('channels must be the same for elements of self, or at least the same length');
    end
end
nChannels = length(channels);

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
allMarkers = [self.FreqMarkers];
if isempty(allMarkers), isMarkers = 0;end
if isMarkers
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

% create data
data = [];
for ii = 1:numel(self)
    data = cat(3, data, self(ii).Data);
end
data = permute(data,[3 1 2]); % new order : elements x freq x channels

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
    if self(1).isNumFreq % Freq property is a numeric vector
        imagesc(averageFreq, [], data(:,:,ii));
    else
        imagesc(averageFreq,[],data(:,:,ii));
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
                    plot([t t], [a(3) a(4)], argFmCommon{:}, argFmSpecific_current{:});
                    legendTmp = [legendTmp allMarkers(jj).MarkerName];
                end
            end
        else
            warning('impossible to draw FreqMarkers when Freq is not numeric');
        end
    end
    
    if ~self(1).isNumFreq
        freqs = {self.Freq};
        if ~isequal(freqs{:})
            warning('freqs differ between elements of the FreqSignal');
        else
            set(gca,'XTick',1:length(self.Freq), 'XTickLabel', self.Freq);
        end
        a = axis;
        axis([a(1)-1 a(2)+1 a(3) a(4)]);
    end
    
    title(channels{ii})
    set(gca,'YTick',[]);
    xlabel('Frequency')
    legend(legendTmp)
    legend hide
    hold off
    
end