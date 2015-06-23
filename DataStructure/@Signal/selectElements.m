% Method for class 'Signal' and subclasses
%  selectElements : select the elements of a Signal vector
% INPUTS
    % 
% OUTPUT
    % selectedSignal : select Signal elements


function [selectedSignal, res] = selectElements(self, filter)

% init
selectedSignal = self;

% switch between filters
if isnumeric(filter)
    res = filter;
elseif isfunc(filter)
    res = arrayfun(filter, self); % must be logical
elseif isempty(filter)
    res = [];
end

% select
selectedSignal = selectedSignal(res);
  
if islogical(res)
    res = find(res);
end


end
