% Method for class 'SampledTimeSignal'
% Removal of line noise power of a 'Signal' object
% Requires Chronux toolbox (use of rmlinesc function)
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



function rmlineSignal = lineNoiseRemoval(self, freq, varargin)

% check dimensions
if ~isequal(self.DimOrder, {'time','chan'});
    error('rmlinesc can only be applied on TimeSignal objects with dimensions ''time'' and ''chan''');
end

% handle default parameters
% window width
if nargin < 2 % || isempty(freq) -> empty means 'let Chronux statistically find the freq'
    freq = 50; % rmlinesc computes the lines to remove
end

% copy of the object
rmlineSignal = self;

for ii = 1:numel(self)
    params.Fs = self(ii).Fs;
    rmlineSignal(ii).Data = rmlinesc(self(ii).Data, params, [], [], freq);
    % history
    rmlineSignal(ii).History{end+1,1} = datestr(clock);
    rmlineSignal(ii).History{end,2} = ...
        'Apply rmlinesc to remove the baseline electric noise';
end

end