% Method for class 'Signal' and subclasses
%  selectElements : select the elements of a Signal vector
% INPUTS
    % 
% OUTPUT
    % selectedSignal : select Signal elements


function selectedSignal = selectElements(self, filter)

% init
selectedSignal = self;

% switch between filters
if isnumeric(filter)
    res = filter;
elseif isfunc(filter)
    res = arrayfun(filter, self); % must be logical
end

% sort
selectedSignal = selectedSignal(res);
    
end
