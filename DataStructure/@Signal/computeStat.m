% Method for class 'Signal'
% Compute stat values on the Data property of a 'Signal' object
% INPUTS
% OUTPUT



function [statVal,statP, statMask] = computeStat(self, varargin)

% operate
statVal = self(1);
statP = self(1);
statMask = self(1);

% method
if ~isempty(varargin)
    if ischar(varargin{1}) % kvPairs
        methodInd = find(strcmpi(varargin, 'method'));
        method = varargin{methodInd+1};
        varargin(methodInd:methodInd+1) = [];
    end
end
if ~exist('method','var') % default
    method = 'ttest';
end

% compute
switch method
    case 'ttest'
        self = self(:);
        for ii = 1:numel(statVal.Data)
            sample = arrayfun(@(x) x.Data(ii), self);
            [a, b, ~, d] = ttest(sample, varargin{:});
            statVal.Data(ii) = d.tstat;
            statP.Data(ii) = b;
            statMask.Data(ii) = a;
        end
    case 'wilcoxon'
        self = self(:);
        for ii = 1:numel(statVal.Data)
            sample = arrayfun(@(x) x.Data(ii), self);
            [a, b, ~, d] = signrank(sample, varargin{:});
            statVal.Data(ii) = d.signedrank;
            statP.Data(ii) = b;
            statMask.Data(ii) = a;
        end
end


% history
statVal.History{end+1,1} = datestr(clock);
statVal.History{end,2} = 'Stat values on the Data';
statMask.History{end+1,1} = datestr(clock);
statMask.History{end,2} = 'Stat mask on the Data';
statP.History{end+1,1} = datestr(clock);
statP.History{end,2} = 'P-values on the Data';

end
