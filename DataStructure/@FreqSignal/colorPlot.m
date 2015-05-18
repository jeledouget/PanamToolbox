% COLORPLOT
% plot the 'FreqSignal' elements as columns of a colorplot (data vs.
% frequency bins). Each element must have the same Freq property
% valid only if number of dimensions <= 2 in Data property
% WARNING : if severalcahnnels are present, they will be averaged or
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

% common options for FreqMarkers
isMarkers = 1; % default : show Markers
fm = find(strcmpi(commonOptions,'freqmarkers'));
argFmCommon = {'LineWidth',2}; % default
if ~isempty(fm)
    if ischar(commonOptions{fm+1})
        if strcmpi(commonOptions{fm+1}, 'no')
            isMarkers = 0;
        else % void char, or 'yes' ...
            % do nothing
        end
    else
        argFmCommon = [argFmCommon commonOptions{fm+1}];
    end
    commonOptions(fm:fm+1) = [];
end

% colormap for main plot
cm = find(strcmpi(commonOptions,'colormap'));
nChannels = arrayfun(@(x) length(x.ChannelTags), self);
nChannelsMax = max(nChannels);
if ~isempty(cm)
    cmap = commonOptions{cm+1};
    commonOptions(cm:cm+1) = [];
else
    cmap = 'lines'; % default colormap
end
eval(['cmap = ' cmap '(nChannelsMax);']);
cmap = mat2cell(cmap, ones(1,nChannelsMax),3);
    
% specific options and colorbars for freqMarkers
if isMarkers
    allMarkers = [self.FreqMarkers];
    allMarkers = allMarkers.unifyMarkers;
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
    fm = find(strcmpi(specificOptions,'freqmarkers'));
    if ~isempty(fm)
        argFmSpecific = [argFmSpecific specificOptions{fm+1}];
        specificOptions(fm:fm+1) = [];
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
if self(1).isNumFreq
    imagesc(averageFreq,[],data);
else
    imagesc(1:size(data,1),[],data);
end
axis tight

% plot FreqMarkers
legendTmp = {};
if isMarkers % draw lines for Freq
    if self(1).isNumFreq
        a  = axis;
        for ii = 1:length(allMarkers)
            argFmSpecific_current = argFmSpecific;
            for jj = 2:2:length(argFmSpecific)
                argFmSpecific_current{jj} = argFmSpecific{jj}{ii};
            end
            for kk = 1:length(allMarkers(ii).Freq)
                t = allMarkers(ii).Freq(kk);
                plot([t t], [a(3) a(4)], argFmCommon{:}, argFmSpecific_current{:});
                legendTmp = [legendTmp allMarkers(ii).MarkerName];
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

xlabel('Frequency')
legend(legendTmp)
legend hide
hold off

end