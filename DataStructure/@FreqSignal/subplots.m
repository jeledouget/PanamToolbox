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

% default
if nargin < 3 || isempty(specificOptions)
    specificOptions = {};
end
if nargin < 2 || isempty(commonOptions)
    commonOptions = {};
end

% number of channels
nChannels = length(self.ChannelTags);

% default color
commonOptions = [{'color','k'} commonOptions];

% colormap
cm = find(strcmpi(commonOptions,'colormap'));
if ~isempty(cm)
    cmap = commonOptions{cm+1};
    eval(['cmap = ' cmap '(nChannels);']);
    cmap = mat2cell(cmap, ones(1,nChannels),3);
    specificOptions{end+1} = 'color';
    specificOptions{end+1} = cmap;
    commonOptions(cm:cm+1) = [];
end

% common options for freqMarkers
isFreqMarkers = 1; % default : show FreqMarkers
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
figure;
[horDim, vertDim] = panam_subplotDimensions(nChannels);
for ii = 1:nChannels
    specificOptions_current = specificOptions;
    for jj = 2:2:length(specificOptions)
        specificOptions_current{jj} = specificOptions{jj}{ii};
    end
    options = [commonOptions, specificOptions_current];
    h(ii) = subplot(horDim, vertDim, ii);
    hold on
    legendTmp = {}; % init legend
    if self.isNumFreq % Freq property is a numeric vector
        plot(self.Freq, self.Data(:,ii), options{:});
    else
        plot(self.Data(:,ii), options{:});
        set(gca,'XTick',1:length(self.Freq), 'XTickLabel', self.Freq);
        a = axis;
        axis([a(1)-1 a(2)+1 a(3) a(4)]);
    end
    legendTmp = [legendTmp, self.ChannelTags{ii}];
    
    % plot freqMarkers
    if isFreqMarkers % draw lines for Freq
        if self.isNumFreq
            a  = axis;
            for jj = 1:length(self.FreqMarkers)
                argFmSpecific_current = argFmSpecific;
                for kk = 2:2:length(argFmSpecific)
                    argFmSpecific_current{kk} = argFmSpecific{kk}{jj};
                end
                for kk = 1:length(self.FreqMarkers(jj).Freq)
                    freq = self.FreqMarkers(jj).Freq(kk);
                    plot([freq freq], [a(3) a(4)], argFmCommon{:}, argFmSpecific_current{:});
                    legendTmp = [legendTmp self.FreqMarkers(jj).MarkerName];
                end
            end
        else
            warning('impossible to draw FreqMarkers when Freq is not numeric');
        end
    end
    
    xlabel('Frequency')
    legend(h(ii), legendTmp);
    legend hide
end

end

