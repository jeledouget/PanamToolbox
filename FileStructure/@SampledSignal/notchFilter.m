% Method for class 'SampledSignal'
% 50Hz notch filtering of a 'Signal' object
% A Butterworth filter is applied 
% The user has handle over the width of the notched frequency window and filter order
% Default frequency is 50Hz (electric baseline in Europe)
% Default width is 2Hz (Window : 49-51 Hz)
% Default filter order is 2
% REQUIREMENTS
    % dimensions must be 'time' and 'chan' (no supplementary dimensions)
% INPUTS
    % width :  width the filter window (default  = 2)
    % order : order of the filter (default = 2)  
% OUTPUT
    % notchedSignal : notched 'Signal' object
% SEE ALSO
% BandPassFilter, HighPassFilter, LowPassFilter



function notchedSignal = notchFilter(self, width, order, freq)

% check dimensions
if ~isequal(self.DimOrder, {'time','chan'});
    error('notchFilter can only be applied on TimeSignal objects with dimensions ''time'' and ''chan''');
end

% handle default parameters
% window width
if nargin < 4 || isempty(freq)
    freq = 50; % Europe electric baseline
end
% filter order
if nargin < 3 || isempty(order)
    order = 2;
end
% window width
if nargin < 2 || isempty(width)
    width = 1;
end


% copy of the object
notchedSignal = self;

% notch filter each channel
for j = 1 : size(self.Data,self.dimIndex('chan'))
    x = self.Data(:,j);
    [b,a] = butter(order,([freq-width/2 freq+width/2]/(self.Fs/2)),'stop');
    x(isnan(x))=0;
    x =  filtfilt (b,a,x);
    notchedSignal.Data(:,j) = x;
end

% history
notchedSignal.History{end+1,1} = datestr(clock);
notchedSignal.History{end,2} = ...
        ['Notch filtering (50Hz): window width ' num2str(width) 'Hz, filter order ' num2str(order)];
    
end