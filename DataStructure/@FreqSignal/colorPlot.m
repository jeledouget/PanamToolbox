% COLORPLOT
% plot the 'FreqSignal' elements as columns of a colorplot (data vs.
% frequency bins)
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

% check input
if ~all(arrayfun(@isNumFreq, self)) || ~any(arrayfun(@isNumFreq, self))
    error('Freq property of the elements of the FreqSignal must be all numeric or all discrete');
end
if nargin > 1 && ~iscell(commonOptions)
    commonOptions = [commonOptions, specificOptions, varargin];
    specificOptions = {};
end

% make self a column
self = self(:);

% several channels : average or superimpose ?
handleChannels = 'average'; % default : average channels
hc = find(strcmpi(commonOptions,'handlechannels'));
if ~isempty(hc)
    if find(strcmpi(hc, {'average', 'avg'}))
        handleChannels = 'average';
    elseif find(strcmpi(hc, { 'superimpose', 'stack'}))
        handleChannels = 'superimpose;
    else
        error('handlechannels options must be ''average'' or ''superimpose''');
    end
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
eval(['cmap = ' cmap '(nChannelsMax));']);
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
        if self(kk).isNumFreq % numeric freq vector
            plot(self(kk).Freq, self(kk).Data(:,ii), options{:});
        else
            plot(self(kk).Data(:,ii), options{:});
        end
        legendTmp = [legendTmp, self(kk).ChannelTags{ii}];
    end
end




end