% Method for class 'SampledTimeSignal'
% Compute the power spectrum density by the method of your choice
% INPUTS
% OUTPUT



function psdSignal = psd(self, varargin)



% history
for ii = 1:numel(psdSignal)
    psdSignal(ii).History{end+1,1} = datestr(clock);
    psdSignal(ii).History{end,2} = ...
        'Compute time-frequency power spectrum';
end

end

