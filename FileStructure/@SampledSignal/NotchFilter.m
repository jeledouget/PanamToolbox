% Method for class 'Signal'
% 50Hz notch filtering of a 'Signal' object
% A Butterworth filter is applied 
% The user has handle over the width of the notched frequency window and filter order
% Default width is 2Hz (Window : 49-51 Hz)
% Default filter order is 2
% INPUTS
    % width :  width the filter window (default  = 2)
    % order : order of the filter (default = 2)  
% OUTPUT
    % notchedSignal : notched 'Signal' object
% SEE ALSO
% BandPassFilter, HighPassFilter, LowFilter methods



function notchedSignal = NotchFilter(self, width, order)


% handle default parameters
% filter order
if nargin < 3 || isempty(order)
    order = 2;
end
% window width
if nargin < 2 || isempty(width)
    width = 2;
end


% copy of the object
notchedSignal = self;

% notch filter each channel
for j = 1 : size(self.Data,1)
    x = self.Data(j,:);
    [b,a] = butter(order,([50-width/2 50+width/2]/(self.Fech/2)),'stop');
    x(isnan(x))=0;
    x =  filtfilt (b,a,x);
    notchedSignal.Data(j,:) = x;
end

% history
notchedSignal.History{end+1,1} = datestr(clock);
notchedSignal.History{end,2} = ...
        ['Notch filtering (50Hz): window width ' num2str(width) 'Hz, filter order ' num2str(order)];
    
end