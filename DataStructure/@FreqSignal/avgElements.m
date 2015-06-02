% Method for class 'FreqSignal' and subclasses
%  avgElements : average the elements of a FreqSignal object
% elements must have the same dimensions
% INPUTS
%
% OUTPUT
% avgSignal : between-elements FreqSignal average


function avgSignal = avgElements(self, subclassFlag)

% check input
if ~all(arrayfun(@isNumFreq, self)) || ~any(arrayfun(@isNumFreq, self))
    error('Freq property of the elements of the FreqSignal must be all numeric or all discrete');
end

% check that Freq property is the same for each element of self
if numel(self) > 1 && ~isequal(self.Freq)
    lengths = arrayfun(@(x) length(x.Freq), self);
    if any(lengths(2:end) - lengths(1:end-1)) % lengths of Freq differ among elements of self
        error('Freq properties are not of the same length');
    elseif self(1).isNumFreq
        averageFreq = mean(reshape([self.Freq],[],numel(self)),2);
        for ii = 1:numel(self)
            orderFreq{ii} = arrayfun(@(x) panam_closest(averageFreq, x), self(ii).Freq);
        end
        if isequal(orderFreq{:}, 1:lengths(1))
            warning('frequencies are not exactly the same in all elements of the FreqSignal');
        else
            error('Frequencies should be the same');
        end
    else % discrete Frequencies
        error('Frequencies should have the same tag. Check Freq properties');
    end
elseif self(1).isNumFreq
    averageFreq = mean(reshape([self.Freq],[],numel(self)),2);
end

% average
avgSignal = self.avgElements@Signal(1);
avgSignal.Freq = averageFreq;
markers = [self.FreqMarkers];
if ~isempty(markers)
    markers = markers.unifyMarkers(0).avgMarkers;
    avgSignal.FreqMarkers = markers;
end

% history
if ~subclassFlag
    avgSignal.History{end+1,1} = datestr(clock);
    avgSignal.History{end,2} = ...
        'Average the elements of the FreqSignal object';
end

end
