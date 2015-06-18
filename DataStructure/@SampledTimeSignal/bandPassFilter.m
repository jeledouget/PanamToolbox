% Method for class 'SampledTimeSignal'
% Band-pass filtering of a 'SampledTimeSignal' object
% A Butterworth filter is applied
% The user has handle over cutoff frequency and filter order
% Default filter order is 2
% REQUIREMENTS
% dimensions must be 'time' and 'chan' ( no supplementary dimensions)
% INPUTS
% cutoffLow :  low cutoff frequency of the filter
% cutoffHigh :  high cutoff frequency of the filter
% order : order of the filter (default = 2)
% OUTPUT
% bpFilteredSignal : band-pass filtered 'Signal' object
% SEE ALSO
% LowPassFilter, HighPassFilter, NotchFilter



function bpFilteredSignal = bandPassFilter(self, cutoffLow, cutoffHigh, order)

% check dimensions
if ~isequal(self.DimOrder, {'time','chan'});
    error('bandPassFilter can only be applied on TimeSignal objects with dimensions ''time'' and ''chan''');
end

% handle default parameters
% filter order
if nargin < 4 || isempty(order)
    order = 2;
end

% copy of the object
bpFilteredSignal = self;

for ii  = 1:numel(self)
    % band-pass each channel
    for j = 1 : size(self(ii).Data,self(ii).dimIndex('chan'))
        x = self(ii).Data(:,j);
        [b,a] = butter(order,[cutoffLow cutoffHigh]/(self(ii).Fs/2));
        x(isnan(x))=0;
        x =  filtfilt (b,a,x);
        bpFilteredSignal(ii).Data(:,j) = x;
    end
    
    % history
    bpFilteredSignal(ii).History{end+1,1} = datestr(clock);
    bpFilteredSignal(ii).History{end,2} = ...
        ['Band-pass filtering : cutoff ' num2str(cutoffLow) '-' num2str(cutoffHigh) 'Hz, filter order ' num2str(order)];
end

end