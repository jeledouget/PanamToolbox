% SUBPLOTS
% plot the 'FreqSignal' as data vs. frequency bins, one subplot per channel
% valid only if number of dimensions <= 2 in Data property
% INPUTS :
    % commonOptions : cell of key-values pairs for plot properties that will
    % be shared by plots of all channels
    % specificOptions : cell of key-values pairs for plot properties that
    % will are specific to each channels ; each values of key-value pair
    % must be cell of length nChannels
% OUTPUTS :
    % h : handle to the axes of the plot
    

function h = subplots(self, commonOptions, specificOptions)

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
nSignals = numel(self);

% default
if nargin < 3 || isempty(specificOptions)
    specificOptions = {};
end
if nargin < 2 || isempty(commonOptions)
    commonOptions = {};
end

% common options for freqmarkers
isMarkers = 1; % default : show FreqMarkers
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

% channels
nChannels = arrayfun(@(x) length(x.ChannelTags), self);
if length(unique(nChannels)) == 1 % channel length always the same
    nChannels = max(nChannels);
    if numel(self) < 2 || isequal(self.ChannelTags) % are ChannelTags the same for all elements of self ?
       identicChannels = 1;
    else
       warning('channels do not have the same names among different elements of the FreqSignal object');
       identicChannels = 0;
    end
else
    error('subplots method cannot be applied if the number of channels differ between elements of the FreqSignal object');
end

% colormap for channels
cm = find(strcmpi(commonOptions,'colormap'));
if ~isempty(cm)
    cmap = commonOptions{cm+1};
    commonOptions(cm:cm+1) = [];
else
    cmap = 'lines'; % default colormap
end
if isMarkers
    allMarkers = [self.FreqMarkers];
    allMarkers = allMarkers.unifyMarkers;
    nMarkers = length(allMarkers);
    if strcmpi(cmap, 'lines')
        eval(['cmap = ' cmap '(nSignals + nMarkers);']);
    else
        eval(['cmap = cat(1,' cmap '(nSignals), lines(nMarkers));']);
    end
    cmap = mat2cell(cmap, ones(1,nSignals + nMarkers),3);
else
    eval(['cmap = ' cmap '(nSignals);']);
    cmap = mat2cell(cmap, ones(1,nSignals),3);
end

% specific options and colorbars for FreqMarkers
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
        cmap_fm = cmap(nSignals+1:end);
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
        if self(kk).isNumFreq % Freq property is a numeric vector
            plot(self(kk).Freq, self(kk).Data(:,ii), options{:});
        else
            plot(self(kk).Data(:,ii), options{:});
            set(gca,'XTick',1:length(self(kk).Freq), 'XTickLabel', self(kk).Freq);
            a = axis;
            axis([a(1)-1 a(2)+1 a(3) a(4)]);
        end
        if identicChannels
            legendTmp = [legendTmp, ['signal ' num2str(kk)]];
        else
            legendTmp = [legendTmp, ['signal ' num2str(kk) ' ' self(kk).ChannelTags{ii}]];
        end
    end
    
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
    
    xlabel('Frequency')
    legend(h(ii), legendTmp)
    legend hide
    if identicChannels
        title(self(1).ChannelTags{ii})
    else
        title(['channel ' num2str(ii)])
    end
end


end

