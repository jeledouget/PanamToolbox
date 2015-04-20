% Method for class 'SampledTimeSignal'
% RMS_Signal: compute the Root Mean Square of the Signal over a defined Time Window
% around each time point. Default window is 1s
% NaNs are affected when the RMS can't be computed (not enough points on
% left or right side)
% INPUTS
    % timeWindow : length of the time window on which the RMS is computed (default = 1)
% OUTPUT
    % RmsSignal : RMS signal

    

function RmsSignal = RMS_Signal(self, timeWindow)

% handles default parameters
if nargin < 2 || isempty(timeWindow)
    timeWindow = 1;
end

% copy of the object
RmsSignal = self;

% compute RMS
squaredData = RmsSignal.Data .^ 2; % square signal
nSamplesHalf = round(timeWindow * RmsSignal.Fs / 2); % number of samples
dims = size(RmsSignal.Data);
for ii = 1:size(RmsSignal.Data,1)
    if ii <= nSamplesHalf || ii >= size(squaredData,1)-nSamplesHalf
        RmsSignal.Data(ii,:) = nan;
    else
        dataTemp = reshape(squaredData(ii-nSamplesHalf:ii+nSamplesHalf,:),[2*nSamplesHalf+1, dims(2:end)]);
        RmsSignal.Data(ii,:) = reshape(sqrt(mean(dataTemp,1)), 1, []);
    end
end

% history
RmsSignal.History{end+1,1} = datestr(clock);
RmsSignal.History{end,2} = ...
        ['Root Mean Square of the signal over a time window of ' num2str(timeWindow) 's'];

end