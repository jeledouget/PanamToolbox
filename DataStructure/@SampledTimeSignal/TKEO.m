% Method for class 'SampledTimeSignal'
% Compute TKEO of a 'SampledTimeSignal' object
% cf : Teager Kaiser energy operator signal conditioning improves EMG onset detection (Solnik et al., 2010)
% INPUTS
% OUTPUT
    % TKEOSignal : TKEO'd 'Signal' object



function TKEOSignal = TKEO(self)

% copy of the object
TKEOSignal = self;

% compute TKEO of the signal
TKEOSignal.Data(2:end-1,:) = self.Data(2:end-1,:).*self.Data(2:end-1,:) - self.Data(1:end-2,:).*self.Data(3:end,:);
TKEOSignal.Data(1,:) = NaN;
TKEOSignal.Data(end,:) = NaN;

% history
TKEOSignal.History{end+1,1} = datestr(clock);
TKEOSignal.History{end,2} = ...
        'Process TKEO of the signal';

end