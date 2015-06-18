% Method for class 'SampledTimeSignal'
% Low-pass filtering of a 'SampledTimeSignal' object
% A Butterworth filter is applied
% The user has handle over cutoff frequency and filter order
% Default filter order is 2
% REQUIREMENTS
% dimensions must be 'time' and 'chan' ( no supplementary dimensions)
% INPUTS
% cutoff : cutoff frequency of the filter
% order : order of the filter (default = 2)

% OUTPUT
% lpFilteredSignal : low-pass filtered 'SampledTimeSignal' object

% SEE ALSO
% BandPassFilter, HighPassFilter, NotchFilter



function lpFilteredSignal = lowPassFilter(self, cutoff, order)

% check dimensions
if ~isequal(self.DimOrder, {'time','chan'});
    error('lowPassFilter can only be applied on TimeSignal objects with dimensions ''time'' and ''chan''');
end

% handle default parameters
% filter order
if nargin < 3 || isempty(order)
    order = 2;
end

% copy of the object
lpFilteredSignal = self;

for ii = 1:numel(self)
    % low-pass each channel
    for j = 1 : size(self(ii).Data,self(ii).dimIndex('chan'))
        x = self(ii).Data(:,j);
        [b,a] = butter(order,(cutoff/(self(ii).Fs/2)),'low');
        x(isnan(x))=0;
        x =  filtfilt (b,a,x);
        lpFilteredSignal(ii).Data(:,j) = x;
    end
    
    % history
    lpFilteredSignal(ii).History{end+1,1} = datestr(clock);
    lpFilteredSignal(ii).History{end,2} = ...
        ['Low-pass filtering : cutoff ' num2str(cutoff) 'Hz, filter order ' num2str(order)];
end

end