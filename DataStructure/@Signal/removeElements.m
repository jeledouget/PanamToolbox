% Method for class 'Signal' and subclasses
%  removeElements : remove the elements of a Signal vector
% INPUTS
    % 
% OUTPUT
    % outSignal :  Signal matrix without removed elements


function [outSignal, res] = removeElements(self, filter)

% init
outSignal = self;

% switch between filters
if isnumeric(filter)
    res = filter;
elseif isa(filter, 'function_handle')
    res = arrayfun(filter, self); % must be logical
elseif isempty(filter)
    res = [];
end

% remove
outSignal(res) = [];

if islogical(res)
    res = find(res);
end

end
