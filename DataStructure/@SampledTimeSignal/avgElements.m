% Method for class 'SampledTimeSignal' and subclasses
%  avgElements : average the elements of a SampledTimeSignal object
% elements must have the same dimensions
% INPUTS
    % 
% OUTPUT
    % avgSignal : between-elements SampledTimeSignal average



function avgSignal = avgElements(self, varargin)

% check sampling freq
if numel(self) > 1 && ~isequal(self.Fs)
    error('All elements of self must have the same sampling frequency for average');
end

% args & options
if ~isempty(varargin)
    if ischar(varargin{1}) % kvPairs
        varargin = panam_args2struct(varargin);
    else % structure
        varargin = varargin{1};
    end
else
    varargin = [];
end
defaultOption.subclassFlag = 0;
varargin = setstructfields(defaultOption, varargin);

% average
avgSignal = self.avgElements@TimeSignal(varargin);

if avgSignal.isSampled
    avgSignal = avgSignal.toSampledTimeSignal;
end

% history
avgSignal.History{end+1,1} = datestr(clock);
avgSignal.History{end,2} = ...
        'Average the elements of the FreqSignal object';

end
