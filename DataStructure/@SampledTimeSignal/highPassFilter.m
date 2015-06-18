% Method for class 'SampledTimeSignal'
% High-pass filtering of a 'SampledTimeSignal' object
% A Butterworth filter is applied
% The user has handle over cutoff frequency and filter order
% Default filter order is 2
% REQUIREMENTS
% dimensions must be 'time' and 'chan' ( no supplementary dimensions)
% INPUTS
% cutoff : cutoff frequency of the filter
% order : order of the filter (default = 2)
% OUTPUT
% hpFilteredSignal : high-pass filtered 'Signal' object
% SEE ALSO
% BandPassFilter, LowPassFilter, NotchFilter



function hpFilteredSignal = highPassFilter(self, cutoff, order)

% check dimensions
if ~isequal(self.DimOrder, {'time','chan'});
    error('highPassFilter can only be applied on TimeSignal objects with dimensions ''time'' and ''chan''');
end

% handle default parameters
% filter order
if nargin < 3 || isempty(order)
    order = 2;
end

% copy of the object
hpFilteredSignal = self;

for ii = 1:numel(self)
    % high-pass each channel
    for j = 1 : size(self(ii).Data,self(ii).dimIndex('chan'))
        x = self(ii).Data(:,j);
        [b,a] = butter(order,(cutoff/(self(ii).Fs/2)),'high');
        x(isnan(x))=0;
        x =  filtfilt (b,a,x);
        hpFilteredSignal(ii).Data(:,j) = x;
    end
    
    % history
    hpFilteredSignal(ii).History{end+1,1} = datestr(clock);
    hpFilteredSignal(ii).History{end,2} = ...
        ['High-pass filtering : cutoff ' num2str(cutoff) 'Hz, filter order ' num2str(order)];
end

end