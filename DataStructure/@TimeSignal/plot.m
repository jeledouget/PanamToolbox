% PLOT
% plot the 'TimeSignal' as data vs. time bins
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

% common options for Events
isEvents = 1; % default : show Events
ev = find(strcmpi(commonOptions,'events'));
argEvCommon = {'LineWidth',2}; % default
if ~isempty(ev)
    if ischar(commonOptions{ev+1})
        if strcmpi(commonOptions{ev+1}, 'no')
            isEvents = 0;
        else % void char, or 'yes' ...
            % do nothing
        end
    else
        argEvCommon = [argEvCommon commonOptions{ev+1}];
    end
    commonOptions(ev:ev+1) = [];
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
if isEvents
    nEvents = length(self.Events);
    if strcmpi(cmap, 'lines')
        eval(['cmap = ' cmap '(nChannels + nEvents);']);
    else
        eval(['cmap = cat(1,' cmap '(nChannels), lines(nEvents));']);
    end
    cmap = mat2cell(cmap, ones(1,nChannels + nEvents),3);
else
    eval(['cmap = ' cmap '(nChannels);']);
    cmap = mat2cell(cmap, ones(1,nChannels),3);
end
specificOptions = [{'color', cmap(1:nChannels)} specificOptions];
    
% specific options and colorbars for freqMarkers
if isEvents
    argEvSpecific = {}; % init
    % colormap for Events
    cm = find(strcmpi(argEvCommon,'colormap'));
    nEvents = length(self.Events);
    if ~isempty(cm)
        cmap_fm = argEvCommon{cm+1};
        argEvCommon(cm:cm+1) = [];
        eval(['cmap_fm = ' cmap_fm '(nEvents);']);
        cmap_fm = mat2cell(cmap_fm, ones(1,nEvents),3);
    else
        cmap_fm = cmap(nChannels+1:end);
    end
    argEvSpecific{end+1} = 'color';
    argEvSpecific{end+1} = cmap_fm;
    % other options
    fm = find(strcmpi(specificOptions,'events'));
    if ~isempty(fm)
        argEvSpecific = [argEvSpecific specificOptions{fm+1}];
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
    if self.isNumTime % numeric time vector
        plot(self.Time, self.Data(:,ii), options{:});
    else
        plot(self.Data(:,ii), options{:});
    end
    legendTmp = [legendTmp, self.ChannelTags{ii}];
end

% plot Events
if isEvents % draw lines for Time
    if self.isNumTime
        a  = axis;
        for ii = 1:length(self.Events)
            argEvSpecific_current = argEvSpecific;
            for jj = 2:2:length(argEvSpecific)
                argEvSpecific_current{jj} = argEvSpecific{jj}{ii};
            end
            for kk = 1:length(self.Events(ii).Time)
                t = self.Events(ii).Time(kk);
                plot([t t], [a(3) a(4)], argEvCommon{:}, argEvSpecific_current{:});
                legendTmp = [legendTmp self.Events(ii).EventName];
            end
        end
    else
        warning('impossible to draw Events when Time is not numeric');
    end
end

if ~self.isNumTime
    set(gca,'XTick',1:length(self.Time), 'XTickLabel', self.Time);
    a = axis;
    axis([a(1)-1 a(2)+1 a(3) a(4)]);
end

xlabel('Time')
legend(legendTmp)
legend hide
hold off

end

