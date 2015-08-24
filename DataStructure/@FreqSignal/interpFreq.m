% Method for class 'TimeFreqSignal' and subclasses
% interpTimeFreq : interpolate data to other vectors of time and freq samples
% INPUTS
% OUTPUT
% interpSignal :  freq-interpolated 'FreqSignal' object


function interpSignal = interpFreq(self, newFreq, varargin)

interpSignal = self;

% case of 'replace' : just change the frequency vector. Must be the same
% length
if ~isempty(varargin) && strcmpi(varargin{1}, 'replace')
    freqSamples = unique(arrayfun(@(x) numel(x.Freq), self));
    if numel(freqSamples) > 1 || freqSamples ~= numel(newFreq)
        error(' to replace freq vector, all elements must have the same number of freq samples and the new frequency vector must also be the same length');
    end
    for ii = 1:numel(self)
        
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
    return;
    
elseif ~isempty(varargin) && strcmpi(varargin{1}, 'interp1') % use interp1 function
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
    
else % use panam_interpMatrix
    % compute
    for ii = 1:numel(self)
        % dims
        nDims = ndims(self(ii).Data);
        dimFreq = self(ii).dimIndex('freq');
        oldFreq = self(ii).Freq;
        data = permute(self(ii).Data, [dimFreq 1:dimFreq-1 dimFreq+1:nDims]);
        iM = panam_interpMatrix(oldFreq, newFreq, varargin{:}); % interpolation matrix
        data = iM' * data;
        
        % affect changes
        interpSignal(ii).Data = permute(data, [2:dimFreq 1 dimFreq+1:nDims]);
        interpSignal(ii).Freq = newFreq;
        
        % handle events
        interpSignal(ii).FreqMarkers = interpSignal(ii).FreqMarkers.asList;
        indToRemove = arrayfun(@(x) (x.Freq > newFreq(end) || x.Freq < newFreq(1)), interpSignal(ii).FreqMarkers);
        interpSignal(ii).FreqMarkers(indToRemove) = [];
        
        % history
        interpSignal(ii).History{end+1,1} = datestr(clock);
        interpSignal(ii).History{end,2} = ...
            'Interpolate data to a new time vector : panam_interpMatrix';
    end
end


end

