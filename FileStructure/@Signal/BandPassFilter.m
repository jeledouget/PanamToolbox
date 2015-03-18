% Band-pass filtering of a 'Signal' object
% A Butterworth filter is applied 
% The user has handle over cutoff frequency and filter order
% Default filter order is 2
% INPUTS
    % cutoffLow :  low cutoff frequency of the filter
    % cutoffHigh :  high cutoff frequency of the filter 
    % order : order of the filter (default = 2)   
% OUTPUT
    % bpFilteredSignal : band-pass filtered 'Signal' object
% SEE ALSO
% LowPassFilter, HighPassFilter, NotchFilter methods



function bpFilteredSignal = BandPassFilter(self, cutoffLow, cutoffHigh, order)

% handle default parameters
% filter order
if nargin < 4 || isempty(order)
    order = 2;
end

% copy of the object
bpFilteredSignal = self;

% band-pass each channel
for j = 1 : size(self.Data,1)
    x = self.Data(j,:);
    [b,a] = butter(order,[cutoffLow cutoffHigh]/(self.Fech/2));
    x(isnan(x))=0;
    x =  filtfilt (b,a,x);
    bpFilteredSignal.Data(j,:) = x;
end

% history
bpFilteredSignal.History{end+1,1} = datestr(clock);
bpFilteredSignal.History{end,2} = ...
        ['Band-pass filtering : cutoff ' num2str(cutoffLow) '-' num2str(cutoffHigh) 'Hz, filter order ' num2str(order)];

end