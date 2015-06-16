% Method for class 'TimeFreqSignal' and subclasses
%  toFieldTrip : create a FieldTrip structure from the TimeFreqSignal matrix
% INPUTS
% varargin : contains optional fields, as a structure or key-value pairs.
% notably, the type of data (powspctrm(default), fouriesspctrm, csdspctrm, cohspctrm...) can be explicited
% OUTPUT
% tfStruct :  FieldTrip TIMEFREQ structure


function ftStruct = toFieldTrip(self, varargin)

% check dimensions
if ~all(arrayfun(@(x) isequal(x.DimOrder, {'time', 'freq', 'chan'}), self))
    error('this method only applies for time x freq x chan Data');
end

% make self a row
self = self(:)';

% required field : label
% check that all labels are the same among elements of self
if numel(self) > 1 && ~isequal(self.ChannelTags)
    error('to creae a FieldTrip structure from this object, elements must have the same ChannelTags property');
end
ftStruct.label = self(1).ChannelTags;

% required field : time
% check that time is the same among elements of self
if numel(self) > 1 && ~isequal(self.Time)
    error('to create a FieldTrip structure from this object, elements must have the same Time property');
end
ftStruct.time = self(1).Time;

% required field : freq
% check that freq is the same among elements of self
if numel(self) > 1 && ~isequal(self.Freq)
    error('to create a FieldTrip structure from this object, elements must have the same Freq property');
end
ftStruct.freq = self(1).Freq;

% required field : dimord
ftStruct.dimord = 'rpt_chan_freq_time';

% data
for ii = 1:numel(self)
    ftStruct.powspctrm(ii,:,:,:) = permute(self(ii).Data,[3 2 1]);
end

% optional outputs
if ~isempty(varargin)
    if ischar(varargin{1}) % key-value pairs as varargin
        varargin{1} = panam_args2struct(varargin);
    end
    % check the type of data, change if necessary
    f = fieldnames(varargin{1});
    if strcmpi(f, 'ftspectraltype')
        type = varargin{1}.(f{strcmpi(f, 'ftspectraltype')});
        varargin{1} = rmfield(varargin{1}, f{strcmpi(f, 'ftspectraltype')});
        if ~strcmpi(type, 'powspctrm')
            ftStruct.(type) = ftStruct.powspctrm;
            ftStruct = rmfield(ftStruct, 'powspctrm');
        end
    end
    % now varargin is a structure (other options for varargin)
    ftStruct = setstructfields(ftStruct, varargin{1});
end

end
