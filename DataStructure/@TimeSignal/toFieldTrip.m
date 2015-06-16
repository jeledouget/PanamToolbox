% Method for class 'TimeSignal' and subclasses
%  toFieldTrip : create a FieldTrip structure from the TimeSignal matrix
% INPUTS
% OUTPUT
    % ftStruct :  FieldTrip time/trial structure

    
    
function ftStruct = toFieldTrip(self, varargin)


% check dimensions
if ~all(arrayfun(@(x) isequal(x.DimOrder, {'time', 'chan'}), self))
    error('this method only applies for time x chan Data');
end

% make self a row
self = self(:)';

% required field : label
% check that all labels are the same among elements of self
if numel(self) > 1 && ~isequal(self.ChannelTags)
    error('to create a FieldTrip structure from this object, elements must have the same ChannelTags property');
end
ftStruct.label = self(1).ChannelTags;

% required field : time
ftStruct.time = arrayfun(@(x) x.Time, self, 'UniformOutput',0);

% required field : trial
ftStruct.trial = arrayfun(@(x) x.Data', self, 'UniformOutput',0);

% optional outputs
if ~isempty(varargin)
    if ischar(varargin{1}) % key-value pairs as varargin
        varargin{1} = panam_args2struct(varargin);
    end
    % now varargin is a structure (other option for varargin)
    ftStruct = setstructfields(ftStruct, varargin{1});
end

end
