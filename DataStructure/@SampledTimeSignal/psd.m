% Method for class 'SampledTimeSignal'
% Compute the power spectrum density by the method of your choice
% Default method : Welch
% INPUTS
% OUTPUT



function freqSignal = psd(self, varargin)

% args & options
if ~isempty(varargin)
    if ischar(varargin{1}) % kvPairs
        varargin = panam_args2struct(varargin);
    else % structure
        varargin = varargin{1};
    end
    if isfield(varargin, 'method') && ischar(varargin.method)
        varargin.method = str2func(varargin.method);
    end
else
    varargin = [];
end
% default
defaultOption.method = @pwelch;
defaultOption.window = [];
defaultOption.noverlap = [];
defaultOption.overlap = [];
defaultOption.freq = [];
defaultOption.nw = [];
defaultOption.nfft = [];
defaultOption.p = 4; % default 4th order AR filter
option = setstructfields(defaultOption, varargin);

% option for different methods
window = option.window;
noverlap = option.noverlap;
if ~isempty(option.overlap)
    noverlap = round(option.overlap * window);
end
freq = option.freq;
nw = option.nw;
nfft = option.nfft;
p = option.p;
% computation loop
for i = 1:numel(self)
    
    % fs
    fs = self(i).Fs;
    
    % copy the data
    data = self(i).Data;
    
    % args
    switch func2str(option.method)
        case 'pwelch'
            args = {window, noverlap, freq, fs};
        case 'periodogram'
            args = {window, freq, fs};
        case 'pmtm'
            args = {nw, nfft, fs};
        case {'pcov', 'pmcov', 'pmusic', 'peig', 'pyulear'}
            args = {p, freq, fs};
    end
    
    % compute psd
    for j = 1:size(data,2)
        [psdData(j,:), f(j,:)] = option.method(data(:,j), args{:});
    end
    
    % check consistency of frequency vector
    if ~size(unique(f,'rows'),1)==1
        error('this psd method does not output the same number of freq samples for each channel, please update method and args');
    end
    
    % create output
    tmp = rmfield(panam_class2struct(self(i)), {'Data', 'DimOrder', 'History','Time', 'Events', 'Fs'});
    tmp = panam_struct2args(tmp);
    freqSignal(i) = FreqSignal('data', psdData', 'DimOrder', {'freq', 'chan'}, 'freq', f(1,:), tmp{:});
    freqSignal(i).History = cat(1,self(i).History,freqSignal(i).History);
    freqSignal(i) = freqSignal(i).interpFreq(linspace(0, ceil(min([self.Fs])/4), 10*ceil(min([self.Fs])/4) + 1));
    % add history
    freqSignal(i).History{end+1,1} = datestr(clock);
    freqSignal(i).History{end,2} = ...
        'Compute  power spectrum density';
end


end

