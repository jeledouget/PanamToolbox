% Method for class 'SampledTimeSignal'
% Compute the power spectrum density by the method of your choice
% Default method : Welch
% INPUTS
% OUTPUT



function freqSignal = psd(self, varargin)

% args & options
if ~isempty(varargin)
    if ischar(varargin{1})
        method = str2func(varargin{1});
        varargin = varargin(2:end);
    elseif ishandle(varargin{1})
        method = varargin{1};
        varargin = varargin(2:end);
    else
        method = @pwelch; % default
end

% computation loop
for i = 1:numel(self)
    
    % copy the data
    data = self(i).Data;
    
    % compute psd
    for j = 1:size(data,2)
        [psdData(:,j), f(j)] = method(data(:,j), varargin{:});
    end
    
    % check consistency of frequency vector
    if ~numel(unique(f)) == 1
        error('this psd method does not output the same number of freq samples for each channel, please update method and args');
    end
    
    % create output
    freqSignal(i) = FreqSignal;
end

% history
for i = 1:numel(freqSignal)
    freqSignal(i).History{end+1,1} = datestr(clock);
    freqSignal(i).History{end,2} = ...
        'Compute  power spectrum density';
end

end

