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

% colormap
cm = find(strcmpi(commonOptions,'colormap'));
if ~isempty(cm)
    nChannels = length(self.ChannelTags);
    cmap = commonOptions{cm+1};
    eval(['cmap = ' cmap '(nChannels);']);
    cmap = mat2cell(cmap, ones(1,nChannels),3);
    specificOptions{end+1} = 'color';
    specificOptions{end+1} = cmap;
    commonOptions(cm:cm+1) = [];
end

% freqMarkers
isFreqMarkers = 1; % default : show FreqMarkers
fm = find(strcmpi(commonOptions,'freqmarkers'));
argFm = {'color','r'}; % default
if ~isempty(fm)
    if ischar(commonOptions{fm+1})
        if strcmpi(commonOptions{fm+1}, 'no')
            isFreqMarkers = 0;
        else % void char, or 'yes' ...
            % do nothing
        end
    else
        argFm = [argFm commonOptions(fm+1)];
    end
    commonOptions(fm:fm+1) = [];
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


if isFreqMarkers % draw lines for Freq
    if self.isNumFreq
        a  = axis;
        for ii = 1:length(self.FreqMarkers)
            for jj = 1:length(self.FreqMarkers(ii).Freq)
                freq = self.FreqMarkers(ii).Freq(jj);
                plot([freq freq], [a(3) a(4)], argFm{:});
                legendTmp = [legendTmp self.FreqMarkers(ii).MarkerName];
            end
        end
    else
        warning('impossible to draw FreqMarkers when Freq is not numeric');
    end
end

if ~self.isNumFreq
    set(gca,'XTick',1:length(self.Freq), 'XTickLabel', self.Freq);
    a = axis;
    axis([a(1)-1 a(2)+1 a(3) a(4)]);
end

xlabel('Frequency')
legend(self.ChannelTags{:}, legendTmp)
legend hide
hold off

end

