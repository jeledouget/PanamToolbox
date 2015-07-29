% Method for class 'SampledTimeSignal' and subclasses
% hilbertTransform : hilbert transform of a SampledTimeSignal object
% INPUTS
%
% OUTPUT
% avgSignal : between-elements SampledTimeSignal average



function hilbertTransform = hilbert(self, varargin)

% copy of the object
hilbertTransform = self;

% hilbert
for ii = 1:numel(self)
    hilbertTransform(ii).Data = abs(hilbert(self(ii).Data));
    
    % history
    hilbertTransform(ii).History{end+1,1} = datestr(clock);
    hilbertTransform(ii).History{end,2} = ...
        'Compute absolute value of Hilbert transform';
    
end
end
