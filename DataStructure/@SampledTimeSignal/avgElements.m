% Method for class 'SampledTimeSignal' and subclasses
%  avgElements : average the elements of a SampledTimeSignal object
% elements must have the same dimensions
% INPUTS
    % 
% OUTPUT
    % avgSignal : between-elements SampledTimeSignal average



function avgSignal = avgElements(self)

% check sampling freq
if numel(self) > 1 && ~isequal(self.Fs)
    error('All elements of self must have the same sampling frequency for average');
end

% average
avgSignal = self.avgElements@TimeSignal(1);

% history
avgSignal.History{end+1,1} = datestr(clock);
avgSignal.History{end,2} = ...
        'Average the elements of the FreqSignal object';

end
