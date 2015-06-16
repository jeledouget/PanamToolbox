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
operatedSignal.Data = func(self.Data, varargin{:});

% history
operatedSignal.History{end+1,1} = datestr(clock);
operatedSignal.History{end,2} = ['Perform operation ''' func2str(func) ''' on the Data property'];

end