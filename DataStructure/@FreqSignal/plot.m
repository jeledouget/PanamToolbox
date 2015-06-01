% PLOT
% plot the 'FreqSignal' as data vs. frequency bins
% valid only if number of dimensions <= 2 in Data property
% plot the different channels on the same plot
% INPUTS :
    % commonOptions : cell of key-values pairs for plot properties that will
    % be shared by plots of all channels
    % specificOptions : cell of key-values pairs for plot properties that
    % will are specific to each channels ; each values of key-value pair
    % must be cell of length nChannels
% OUTPUTS :
    % h : handle to the axes of the plot
    

function h = plot(self, commonOptions, specificOptions, varargin)


% TODO : check inputs
if ~all(arrayfun(@isNumFreq, self)) || ~any(arrayfun(@isNumFreq, self))
    error('Freq property of the elements of the FreqSignal must be all numeric or all discrete');
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
if isMarkers
    allMarkers = [self.FreqMarkers];
    if isAvgMarkers
        allMarkers = allMarkers.avgMarkers;
    else
        allMarkers = allMarkers.unifyMarkers;
    end
    nMarkers = length(allMarkers);
    if strcmpi(cmap, 'lines')
        eval(['cmap = ' cmap '(nChannelsMax + nMarkers);']);
    else
        eval(['cmap = cat(1,' cmap '(nChannelsMax), lines(nMarkers));']);
    end
    cmap = mat2cell(cmap, ones(1,nChannelsMax + nMarkers),3);
else
    eval(['cmap = ' cmap '(nChannelsMax);']);
    cmap = mat2cell(cmap, ones(1,nChannelsMax),3);
end
    
% specific options and colorbars for freqMarkers
if isMarkers
    argFmSpecific = {}; % init
    % colormap for FreqMarkers
    cm = find(strcmpi(argFmCommon,'colormap'));
    if ~isempty(cm)
        cmap_fm = argFmCommon{cm+1};
        argFmCommon(cm:cm+1) = [];
        eval(['cmap_fm = ' cmap_fm '(nMarkers);']);
        cmap_fm = mat2cell(cmap_fm, ones(1,nMarkers),3);
    else
        cmap_fm = cmap(nChannelsMax+1:end);
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

% plot FreqMarkers
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

