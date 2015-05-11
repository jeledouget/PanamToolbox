% PLOT
% plot the 'FreqSignal' as data vs. frequency bins
% valid only if number of dimensions <= 2 in Data property
% plot the different channels on the same plot


function h = plot(self, commonOptions, specificOptions)


% TODO : check inputs


% default
if nargin < 3 || isempty(specificOptions)
    specificOptions = {};
end
if nargin < 2 || isempty(commonOptions)
    commonOptions = {};
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
eval(['cmap = ' cmap '(nChannels);']);
cmap = mat2cell(cmap, ones(1,nChannels),3);
specificOptions{end+1} = 'color';
specificOptions{end+1} = cmap;

% common options for freqMarkers
isFreqMarkers = 1; % default : show FreqMarkers
fm = find(strcmpi(commonOptions,'freqmarkers'));
argFmCommon = {}; % default
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

% specific options and colorbars for freqMarkers
if isFreqMarkers
    argFmSpecific = {}; % init
    % colormap for freqMarkers
    cm = find(strcmpi(argFmCommon,'colormap'));
    nMarkers = length(self.FreqMarkers);
    if ~isempty(cm)
        cmap = argFmCommon{cm+1};
        argFmCommon(cm:cm+1) = [];
    else
        cmap = 'lines'; % default colormap
    end
    eval(['cmap = ' cmap '(nMarkers);']);
    cmap = mat2cell(cmap, ones(1,nMarkers),3);
    argFmSpecific{end+1} = 'color';
    argFmSpecific{end+1} = cmap;
    % other options
    fm = find(strcmpi(specificOptions,'freqmarkers'));
    if ~isempty(fm)
        argFmSpecific = [argFmSpecific specificOptions{fm+1}];
        specificOptions(fm:fm+1) = [];
    end
end



% plot
h = axes; 
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
legend(self.ChannelTags{:}, legendTmp)
legend hide
hold off

end

