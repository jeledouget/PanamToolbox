% Method for class 'TimeFreqSignal' and subclasses
% interpFreq : interpolate data to another vector of freq samples
% INPUTS
% OUTPUT
% interpSignal :  freq-interpolated 'TimeFreqSignal' object


function interpSignal = interpTimeFreq(self, newTime, newFreq, varargin)

interpSignal = self;

%% version1 : successive interpolations

interpSignal = interpSignal.interpTime(newTime, varargin{:}).interpFreq(newFreq, varargin{:});


%% version 2 : gridfit

% for jj = 1:numel(self)
%     for ii = 1:length(interpSignal(jj).ChannelTags),data{ii} = interpSignal(jj).Data(:,:,ii);end
%     for ii = 1:length(interpSignal(jj).ChannelTags),data{ii} = data{ii}(:);end
%     for ii = 1:length(interpSignal(jj).ChannelTags),
%         data{ii} = gridfit(...
%             repmat(interpSignal(jj).Time, [1 length(interpSignal(jj).Freq)]),...
%             cell2mat(arrayfun(@(x) repmat(x,[1 length(interpSignal(jj).Time)]),interpSignal(jj).Freq,'Uni',0)),...
%             data{ii},...
%             newTime,...
%             newFreq,...
%             varargin{:});
%     end
%     interpSignal(jj).Data = cat(3, data{:});
%     interpSignal(jj).Freq = newFreq;
%     interpSignal(jj).Time = newTime;
% end

%% version 3 : interp2 ; CARAEFUL WITH SPLINE EXTRAPOLATION ...

% for jj = 1:numel(self)
%     % dims
%     nDims = ndims(self(jj).Data);
%     sizes = size(self(jj).Data);
%     dimTime = self(jj).dimIndex('time');
%     oldTime = self(jj).Time;
%     dimFreq = self(jj).dimIndex('freq');
%     oldFreq = self(jj).Freq;
%     [oT, oF] = meshgrid(oldTime, oldFreq);
%     [nT, nF] = meshgrid(newTime, newFreq);
%     data = permute(self(jj).Data, [dimFreq dimTime setdiff(1:nDims, [dimFreq dimTime])]);
%     if isempty(varargin), varargin = {'spline'};end
%     for ii = 1:numel(data)/length(oldTime)/length(oldFreq)
%         interpData(:,:,ii) = interp2(oT, oF, data(:,:,ii), nT, nF, varargin{:});
%     end
%     interpData = reshape(interpData,[length(newFreq) length(newTime) sizes(setdiff(1:nDims, [dimFreq dimTime]))]);
%
%     % affect changes
%     if dimTime < dimFreq
%         interpSignal(jj).Data = permute(interpData, [3:dimTime+1 2 dimTime+2:dimFreq 1 dimFreq+1:nDims]);
%     else
%         interpSignal(jj).Data = permute(interpData, [3:dimFreq+1 1 dimFreq+2:dimTime 2 dimTime+1:nDims]);
%     end
%     interpSignal(jj).Freq = newFreq;
%     interpSignal(jj).Time = newTime;
% end

%% common code

for jj = 1:numel(self)
    
    % handle events
    interpSignal(jj).Events = interpSignal(jj).Events.asList;
    indToRemove = arrayfun(@(x) (x.Time > newTime(end) || x.Time < newTime(1)), interpSignal(jj).Events);
    interpSignal(jj).Events(indToRemove) = [];
    
    % handle markers
    interpSignal(jj).FreqMarkers = interpSignal(jj).FreqMarkers.asList;
    indToRemove = arrayfun(@(x) (x.Freq > newFreq(end) || x.Freq < newFreq(1)), interpSignal(jj).FreqMarkers);
    interpSignal(jj).FreqMarkers(indToRemove) = [];
    
    % history
    interpSignal(jj).History{end+1,1} = datestr(clock);
    interpSignal(jj).History{end,2} = ...
        'Interpolate data to new time and frequency vectors';
end

end