% Method for class 'SampledTimeSignal'
% Compute TKEO of a 'SampledTimeSignal' object
% cf : Teager Kaiser energy operator signal conditioning improves EMG onset detection (Solnik et al., 2010)
% INPUTS
% OUTPUT
% TKEOSignal : TKEO'd 'Signal' object



function TKEOSignal = TKEO(self)

% copy of the object
TKEOSignal = self;

for ii = 1:numel(self)
    % compute TKEO of the signal
    TKEOSignal(ii).Data(2:end-1,:) = self(ii).Data(2:end-1,:).*self(ii).Data(2:end-1,:) - self(ii).Data(1:end-2,:).*self(ii).Data(3:end,:);
    TKEOSignal(ii).Data(1,:) = NaN;
    TKEOSignal(ii).Data(end,:) = NaN;
    
    % history
    TKEOSignal(ii).History{end+1,1} = datestr(clock);
    TKEOSignal(ii).History{end,2} = ...
        'Process TKEO of the signal';
end

end