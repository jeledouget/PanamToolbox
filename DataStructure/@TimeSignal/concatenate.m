% Method for class 'TimeSignal'
% Concatenate 'TimeSignal' objects
% INPUTS
    % otherSignals : vector array or cell of Signals objects to concatenate to
    % self
    % dim : key to the dimension along which mean remval is performed (ex :
    % time), or number of the dimension
% OUTPUT
    % newSignal : 'TimeSignal' object with concatenation of otherSignals



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

% check that all signals are TimeSignal
if any(~cellfun(@(x) isa(x, 'TimeSignal'), otherSignals))
    error('inputs must be TimeSignal type');
end

% handle dimensions
if ischar(dim)
    dimName = dim;
    dim = self.dimIndex(dim);
else
    dimName = self.DimOrder(dim);
end

% concatenate Data
newSignal = self.concatenate@Signal(otherSignals, dim, 1);

% if dimension is Time, concatenate time bins, else check
% that time bins are consistent
if (self.isNumTime && all(cellfun(@isNumTime, otherSignals))) || ...
        (~self.isNumTime && all(~cellfun(@isNumTime, otherSignals)))
    tmp = cellfun(@(x) x.Time, otherSignals,'UniformOutput',0);
else
    error('to be concatenated time bins must be of same type (numeric OR char)');
end
if strcmpi(dimName, 'time')
    time = [self.Time, tmp{:}];
    newSignal.Time = time;
else % check timeuencies are consistent
    time = [{self.Time}, tmp];
    if self.isNumTime % check that the closest time bins in Time keep the indices
        for ii=1:length(otherSignals)
            if any(arrayfun(@(x) panam_closest(self.Time, otherSignals{ii}.Time(x)) - x, 1:length(otherSignals{ii}.Time)))
                error('time vectors differ : concatenation impossible');
            end
        end
    elseif ~isequal(time{:})
        error('time bins must be the same for concatenation');
    end
end

% concatenate events
for ii = 1:length(otherSignals)
    newSignal.Events = [newSignal.Events, otherSignals{ii}.Events];
end
newSignal.Events = newSignal.Events.unifyEvents;

% history
if ~subclassFlag
    newSignal.History{end+1,1} = datestr(clock);
    newSignal.History{end,2} = ...
        'Concatenation of Signals';
end

end