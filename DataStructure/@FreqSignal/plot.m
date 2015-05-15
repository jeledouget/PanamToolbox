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
    

function h = plot(self, commonOptions, specificOptions)


% TODO : check inputs


% default
if nargin < 3 || isempty(specificOptions)
    specificOptions = {};
end
if nargin < 2 || isempty(commonOptions)
    commonOptions = {};
end

% common options for freqMarkers
isFreqMarkers = 1; % default : show Events
fm = find(strcmpi(commonOptions,'freqmarkers'));
argFmCommon = {'LineWidth',2}; % default
if ~isempty(fm)
    if ischar(commonOptions{fm+1})
        if strcmpi(commonOptions{fm+1}, 'no')
            isFreqMarkers = 0;
        else % void char, or 'yes' ...
            % do nothing
        end
    else
        argFmCommon = [argFmCommon commonOptions{fm+1}];
    end
    commonOptions(fm:fm+1) = [];
end

% colormap for channels
cm = find(strcmpi(commonOptions,'colormap'));
nChannels = length(self.ChannelTags);
if ~isempty(cm)
    cmap = commonOptions{cm+1};
    commonOptions(cm:cm+1) = [];
else
    cmap = 'lines'; % default colormap
end
if isFreqMarkers
    nFreqMarkers = length(self.FreqMarkers);
    if strcmpi(cmap, 'lines')
        eval(['cmap = ' cmap '(nChannels + nFreqMarkers);']);
    else
        eval(['cmap = cat(1,' cmap '(nChannels), lines(nFreqMarkers));']);
    end
    cmap = mat2cell(cmap, ones(1,nChannels + nFreqMarkers),3);
else
    eval(['cmap = ' cmap '(nChannels);']);
    cmap = mat2cell(cmap, ones(1,nChannels),3);
end
specificOptions = [{'color', cmap(1:nChannels)} specificOptions];

% specific options and colorbars for freqMarkers
if isFreqMarkers
    argFmSpecific = {}; % init
    % colormap for freqMarkers
    cm = find(strcmpi(argFmCommon,'colormap'));
    nMarkers = length(self.FreqMarkers);
    if ~isempty(cm)
        cmap_fm = argFmCommon{cm+1};
        argFmCommon(cm:cm+1) = [];
        eval(['cmap_fm = ' cmap_fm '(nMarkers);']);
        cmap_fm = mat2cell(cmap_fm, ones(1,nMarkers),3);
    else
        cmap_fm = cmap(nChannels+1:end);
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
nChannels = size(self.Data,2);
legendTmp = {};
for ii = 1:nChannels
    specificOptions_current = specificOptions;
    for jj = 2:2:length(specificOptions)
        specificOptions_current{jj} = specificOptions{jj}{ii};
    end
    options = [commonOptions, specificOptions_current];
    if self.isNumFreq % numeric freq vector
        plot(self.Freq, self.Data(:,ii), options{:});
    else
        plot(self.Data(:,ii), options{:});
    end
    legendTmp = [legendTmp, self.ChannelTags{ii}];
end

% plot freqMarkers
if isFreqMarkers % draw lines for Freq
    if self.isNumFreq
        a  = axis;
        for ii = 1:length(self.FreqMarkers)
            argFmSpecific_current = argFmSpecific;
            for jj = 2:2:length(argFmSpecific)
                argFmSpecific_current{jj} = argFmSpecific{jj}{ii};
            end
            for kk = 1:length(self.FreqMarkers(ii).Freq)
                freq = self.FreqMarkers(ii).Freq(kk);
                plot([freq freq], [a(3) a(4)], argFmCommon{:}, argFmSpecific_current{:});
                legendTmp = [legendTmp self.FreqMarkers(ii).MarkerName];
            end
        end
    else
        warning('impossible to draw FreqMarkers when Freq is not numeric');
    end
end

if ~self.isNumFreq
    set(gca,'XTick', 1:length(self.Freq), 'XTickLabel', self.Freq);
    a = axis;
    axis([a(1)-1 a(2)+1 a(3) a(4)]);
end

xlabel('Frequency')
legend(legendTmp)
legend hide
hold off

end

