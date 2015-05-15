% SUBPLOTS
% plot the 'TimeSignal' as data vs. time bins, one subplot per channel
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

% default color : black. If a color is specified, it will overload this one
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

% common options for events
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

% specific options and colorbars for freqMarkers
if isEvents
    argEvSpecific = {}; % init
    % colormap for freqMarkers
    cm = find(strcmpi(argEvCommon,'colormap'));
    nEvents = length(self.Events);
    if ~isempty(cm)
        cmap = argEvCommon{cm+1};
        argEvCommon(cm:cm+1) = [];
    else
        cmap = 'lines'; % default colormap
    end
    eval(['cmap = ' cmap '(nEvents);']);
    cmap = mat2cell(cmap, ones(1,nEvents),3);
    argEvSpecific{end+1} = 'color';
    argEvSpecific{end+1} = cmap;
    % other options
    ev = find(strcmpi(specificOptions,'events'));
    if ~isempty(ev)
        argEvSpecific = [argEvSpecific specificOptions{ev+1}];
        specificOptions(ev:ev+1) = [];
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
    if self.isNumTime % Time property is a numeric vector
        plot(self.Time, self.Data(:,ii), options{:});
    else
        plot(self.Data(:,ii), options{:});
        set(gca,'XTick',1:length(self.Time), 'XTickLabel', self.Time);
        a = axis;
        axis([a(1)-1 a(2)+1 a(3) a(4)]);
    end
    legendTmp = [legendTmp, self.ChannelTags{ii}];
    
    % plot events
    if isEvents % draw lines for Events
        if self.isNumTime
            a  = axis;
            for jj = 1:length(self.Events)
                argEvSpecific_current = argEvSpecific;
                for kk = 2:2:length(argEvSpecific)
                    argEvSpecific_current{kk} = argEvSpecific{kk}{jj};
                end
                for kk = 1:length(self.Events(jj).Time)
                    t = self.Events(jj).Time(kk);
                    plot([t t], [a(3) a(4)], argEvCommon{:}, argEvSpecific_current{:});
                    legendTmp = [legendTmp self.Events(jj).EventName];
                end
            end
        else
            warning('impossible to draw Events when Time is not numeric');
        end
    end
    
    xlabel('Time')
    legend(h(ii), legendTmp)
    legend hide
end


end

