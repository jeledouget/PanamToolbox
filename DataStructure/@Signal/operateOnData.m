% Method for class 'Signal'
% Perform an operation on the Data property of a 'Signal' object
% INPUTS
% func : function to apply (eg : log10, sqrt, ...)
% varargin : contains supplementary arguments to func
% OUTPUT
% operatedSignal : 'Signal' object onto which operation has been
% performed



function operatedSignal = operateOnData(self, func, varargin)

% operate
operatedSignal = self;

for ii = 1:numel(self)
    operatedSignal(ii).Data = func(self(ii).Data, varargin{:});
    
    % history
    operatedSignal(ii).History{end+1,1} = datestr(clock);
    operatedSignal(ii).History{end,2} = ['Perform operation ''' func2str(func) ''' on the Data property'];
end

end