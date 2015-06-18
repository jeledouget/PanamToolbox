% Method for class 'FreqSignal' and subclasses
%  avgFreq : average Freq property according to specified windows of freq,
%  and affect a freq tag to each averaged window
% INPUTS
% freqBands : cell of 1x2 vectors with first freq and last freq for the
% window of averaging
% freqTags = cell of char with the freq tags
% OUTPUT
% avgSignal : freq-averaged FreqSignal object, with non-numeric Freq
% property(cell of tags)



function avgSignal = avgFreq(self, varargin)

% copy
avgSignal = self;

% check input
arrayfun(@checkInstance, self);

% varargin
if strcmpi(varargin{1}, 'indices')
    isIndices = 1;
    freqBands = varargin{2};
    if length(varargin) > 2
        freqTags = varargin{3};
    end
    if ischar(freqTags)
        freqTags = {freqTags};
    end
else
    isIndices = 0;
    freqBands = varargin{1};
    if length(varargin) > 1
        freqTags = varargin{2};
        if ischar(freqTags)
            freqTags = {freqTags};
        end
    end
end

% check that Freq property is numeric, except if average on indices
if ~isIndices && ~all(arrayfun(@isNumFreq, self(:)))
    error('freqWindow method only applies to FreqSignal objects with a numeric Freq property');
end

% freqBands check
if ~iscell(freqBands)
    freqBands = {freqBands};
end
for ii = 1:length(freqBands)
    if isscalar(freqBands{ii}) % in case of one freq extraction
        freqBands{ii} = [freqBands{ii} freqBands{ii}];
    end
end

% set default freqTags
isDefFreqTags = 1; % default
if exist('freqTags','var')
    isDefFreqTags = 0;
end

for jj = 1:numel(self)
    % compute average data
    nDims = ndims(self(jj).Data);
    dims = size(self(jj).Data);
    dimFreq = self(jj).dimIndex('freq');
    data = zeros(length(freqBands), prod(dims([1:dimFreq-1 dimFreq+1:nDims])));
    dataTmp = permute(self(jj).Data, [dimFreq 1:dimFreq-1 dimFreq+1:nDims]);
    for ii = 1:length(freqBands)
        if isIndices
            minSample = freqBands{ii}(1);
            maxSample = freqBands{ii}(2);
            if self(jj).isNumFreq
                valMinFreq = self(jj).Freq(minSample);
                valMaxFreq = self(jj).Freq(maxSample);
            end
        else
            minFreq = freqBands{ii}(1);
            maxFreq = freqBands{ii}(2);
            [minSample valMinFreq] = panam_closest(self(jj).Freq, minFreq);
            [maxSample valMaxFreq] = panam_closest(self(jj).Freq, maxFreq);
        end
        isExtractUniqueFreq = (freqBands{ii}(1) == freqBands{ii}(2));
        modifiedInput = 0;
        if ~isExtractUniqueFreq && (maxFreq < min(self(jj).Freq) || minFreq > max(self(jj).Freq))
            warning(['input number ' num2str(ii) ' has freq out of range ; closest freq is selected']);
            modifiedInput = 1;
        end
        data(ii,:) = nanmean(dataTmp(minSample:maxSample,:),1);
        if isDefFreqTags
            if self(jj).isNumFreq
                if isExtractUniqueFreq
                    freqTags{ii} = num2str(valMaxFreq,2);
                else
                    freqTags{ii} = ['avg:' num2str(valMinFreq,2) '-' num2str(valMaxFreq,2)];
                end
            else
                freqTags{ii} = ['avg' num2str(ii)];
            end
        end
        if modifiedInput
            freqTags{ii} = [freqTags{ii} ' - ModifiedFromInput'];
        end
    end
    data = reshape(data, [length(freqBands) dims([1:dimFreq-1 dimFreq+1:nDims])]);
    data = permute(data, [2:dimFreq 1 dimFreq+1:nDims]);
    
    % assign output
    avgSignal(jj).Data = data;
    avgSignal(jj).Freq = freqTags;
    
    % check
    avgSignal(jj).checkInstance;
    
    % history
    avgSignal(jj).History{end+1,1} = datestr(clock);
    avgSignal(jj).History{end,2} = ...
        'Average / Extraction on the freq dimension';
end
end
