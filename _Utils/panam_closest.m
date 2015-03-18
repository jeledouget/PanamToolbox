%PANAM_CLOSEST
% Find the index of the closest point in a vector to a specified value
% Useful fot time vector for instance : find the closest time Sample to a
% specific event
% INPUTS
% vect : vector with numerical values
% value : value to be approached
% OUTPUT
%ind : index in the input vector of the closest point
% val : value of the vector at the closest point

function [ind, val] = panam_closest( vect, value)

% input checking
if ~isvector(vect)
    error('1st input must be a numeric vector');
end

% find the closest point
if value == +Inf
    ind = length(vect);
elseif value == -Inf
    ind = 1;
else
    ind = find(abs(vect - value) == min(abs(vect - value)));
end
ind = ind(1); % handle several indices
val = vect(ind);

end

