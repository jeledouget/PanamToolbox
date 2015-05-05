% Method for class 'SampledTimeSignal'
% Concatenate 'SampledTimeSignal' objects
% INPUTS
    % otherSignals : vector array or cell of Signals objects to concatenate to
    % self
    % dim : key to the dimension along which mean remval is performed (ex :
    % time), or number of the dimension
% OUTPUT
    % newSignal : 'SampledTimeSignal' object with concatenation of otherSignals



function newSignal = concatenate(self, otherSignals, dim, subclassFlag)

% default
if nargin < 4 || isempty(subclassFlag)
    subclassFlag = 0;
end
if nargin < 3 || isempty(dim)
    dim = 'chan';
end
if ~iscell(otherSignals)
    otherSignals = num2cell(otherSignals);
end

% check that all signals are FreqSignal
if any(~cellfun(@(x) isa(x, 'SampledTimeSignal'), otherSignals))
    error('inputs must be SampledTimeSignal type');
end

% check sample frequencies
samplingFreq = [self.Fs, cellfun(@(x) x.Fs, otherSignals)];
if length(unique(samplingFreq)) > 1
    error('inputs must have the same sampling frequency. Resample to concatenate if necessary');
end

% concatenate Data
newSignal = self.concatenate@TimeSignal(otherSignals, dim, 1);

% history
if ~subclassFlag
    newSignal.History{end+1,1} = datestr(clock);
    newSignal.History{end,2} = ...
        'Concatenation of Signals';
end

end