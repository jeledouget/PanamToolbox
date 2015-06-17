% PANAM_FTTOSIGNAL
% Transform a FieldTrip structure into a Signal object
% INPUTS
% ftStruct : input FieldTrip structure
% OUTPUT
% signal : output Signal object

function signal = panam_ftToSignal(ftStruct, field)

% case 1 : time signal
if isfield(ftStruct, 'trial') && iscell(ftStruct.trial)
    for ii = 1:length(ftStruct.trial)
        signal(ii) = TimeSignal('data',ftStruct.trial{ii}',...
            'time', ftStruct.time{ii},...
            'channeltags', ftStruct.label);
    end
    if all(arrayfun(@isSampled ,signal))
        signal = arrayfun(@toSampledTimeSignal,signal,'UniformOutput', 0);
        signal = [signal{:}];
    end
else % case 2 : freq or timefreq signal
    % which field
    if isfield(ftStruct, 'powspctrm')
        dataField = 'powspctrm';
    end
    if nargin > 1 && ~isempty(field)
        dataField = field;
    end
    if ~exist('dataField', 'var')
        f = fieldnames(ftStruct);
        fInd = find(~cellfun(@isempty,strfind(f,'spctrm')));
        if length(fields) ~= 1, error('no field to create data from');end
        dataField = f{fInd};
    end
    % dimensions
    dims = strsplit(ftStruct.dimord, '_');
    hasFreq = any(ismember(dims, 'freq', 'rows'));
    hasTime = any(ismember(dims, 'time'));
    hasRpt = any(ismember(dims, 'rpt'));
    if ~hasFreq, error('structure should have a frequency dimension');end
    if hasTime
        if hasRpt
            % check order
            if ~isequal(ftStruct.dimord, 'rpt_chan_freq_time')
                error('dimord should be rpt_chan_freq_time');
            end
            % to Signal
            for ii = 1:size(ftStruct.(dataField),1)
                data =  permute(ftStruct.(dataField)(ii,:,:,:), [4 3 2 1]);
                signal(ii) = TimeFreqSignal('data', data,...
                    'freq', ftStruct.freq,...
                    'time', ftStruct.time,...
                    'channeltags', ftStruct.label);
            end
        else
            % check order
            if ~isequal(ftStruct.dimord, 'chan_freq_time')
                error('dimord should be chan_freq_time');
            end
            % to Signal
            data =  permute(ftStruct.(dataField), [3 2 1]);
            signal = TimeFreqSignal('data', data,...
                'freq', ftStruct.freq,...
                'time', ftStruct.time,...
                'channeltags', ftStruct.label);
        end
    else % no time component
        if hasRpt
            % check order
            if ~isequal(ftStruct.dimord, 'rpt_chan_freq')
                error('dimord should be rpt_chan_freq');
            end
            % to Signal
            for ii = 1:size(ftStruct.(dataField),1)
                data =  permute(ftStruct.(dataField)(ii,:,:), [3 2 1]);
                signal(ii) = FreqSignal('data', data,...
                    'freq', ftStruct.freq,...
                    'channeltags', ftStruct.label);
            end
        else
            % check order
            if ~isequal(ftStruct.dimord, 'chan_freq')
                error('dimord should be chan_freq');
            end
            % to Signal
            data =  permute(ftStruct.(dataField), [2 1]);
            signal = FreqSignal('data', data,...
                'freq', ftStruct.freq,...
                'channeltags', ftStruct.label);
        end
    end
end

