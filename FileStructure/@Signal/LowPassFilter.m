% Low-pass filtering of a 'Signal' object
% A Butterworth filter is applied 
% The user has handle over cutoff frequency and filter order
% Default filter order is 2

% INPUTS
    % cutoff : cutoff frequency of the filter 
    % order : order of the filter (default = 2)
    
% OUTPUT
    % lpFilteredSignal : low-pass filtered 'Signal' object

% SEE ALSO
% BandPassFilter, HighPassFilter, NotchFilter methods



function lpFilteredSignal = LowPassFilter(self, cutoff, order)

% handle default parameters
% filter order
if nargin < 3 || isempty(order)
    order = 2;
end

% copy of the object
lpFilteredSignal = self;

% low-pass each channel
for j = 1 : size(self.Data,1)
    x = self.Data(j,:);
    [b,a] = butter(order,(cutoff/(self.Fech/2)),'low');
    x(isnan(x))=0;
    x =  filtfilt (b,a,x);
    lpFilteredSignal.Data(j,:) = x;
end

% history
lpFilteredSignal.History{end+1,1} = datestr(clock);
lpFilteredSignal.History{end,2} = ...
        ['Low-pass filtering : cutoff ' num2str(cutoff) 'Hz, filter order ' num2str(order)];

end