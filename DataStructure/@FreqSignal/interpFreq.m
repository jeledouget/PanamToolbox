% Method for class 'TimeFreqSignal' and subclasses
% interpTimeFreq : interpolate data to other vectors of time and freq samples
% INPUTS
% OUTPUT
% interpSignal :  freq-interpolated 'FreqSignal' object


function interpSignal = interpFreq(self, newFreq, varargin)

interpSignal = self;

for ii = 1:numel(self)
    % dims
    nDims = ndims(self(ii).Data);
    dimFreq = self(ii).dimIndex('freq');
    oldFreq = self(ii).Freq;
    data = permute(self(ii).Data, [dimFreq 1:dimFreq-1 dimFreq+1:nDims]);
%     indNan = find(isnan(data));
%     data(indNan) = 0;
    if isempty(varargin)
        data = interp1(oldFreq, data, newFreq,'linear','extrap');
    else
        data = interp1(oldFreq, data, newFreq, varargin{:});
    end
%     data(indNan) = nan;
    
    % affect changes
    interpSignal(ii).Data = permute(data, [2:dimFreq 1 dimFreq+1:nDims]);
    interpSignal(ii).Freq = newFreq;
    
    % handle markers
    interpSignal(ii).FreqMarkers = interpSignal(ii).FreqMarkers.asList;
    indToRemove = arrayfun(@(x) (x.Freq > newFreq(end) || x.Freq < newFreq(1)), interpSignal(ii).FreqMarkers);
    interpSignal(ii).FreqMarkers(indToRemove) = [];
    
    % history
    interpSignal(ii).History{end+1,1} = datestr(clock);
    interpSignal(ii).History{end,2} = ...
        'Interpolate data to a new frequency vector';
end

end

