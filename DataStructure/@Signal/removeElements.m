% Method for class 'Signal' and subclasses
%  removeElements : remove the elements of a Signal vector
% INPUTS
    % 
% OUTPUT
    % outSignal :  Signal matrix without removed elements


function outSignal = removeElements(self, filter)

% init
outSignal = self;

% switch between filters
if isnumeric(filter)
    res = filter;
elseif isfunc(filter)
    res = arrayfun(filter, self); % must be logical
end

% sort
outSignal(res) = [];

end
