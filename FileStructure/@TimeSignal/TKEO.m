% Method for class 'Signal'
% Compute TKEO of a 'Signal' object
% cf : Teager?Kaiser energy operator signal conditioning improves EMG onset detection (Solnik et al., 2010)
% INPUTS
% OUTPUT
    % TKEOSignal : TKEO'd 'Signal' object



function TKEOSignal = TKEO(self)

% copy of the object
TKEOSignal = self;

% compute TKEO of the signal
TKEOSignal.Data(:,2:end-1) = self.Data(:,2:end-1).*self.Data(:,2:end-1) - self.Data(:,1:end-2).*self.Data(:,3:end);
TKEOSignal.Data(:,1) = NaN;
TKEOSignal.Data(:,end) = NaN;

% history
zeroMeanSignal.History{end+1,1} = datestr(clock);
zeroMeanSignal.History{end,2} = ...
        'TKEO of the signal';

end