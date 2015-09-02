%PANAM_CLOSEST
% Find the index of the closest point in a vector to a specified value
% Useful fot time vector for instance : find the closest time Sample to a
% specific event
% INPUTS
% vect : vector with numerical values
% value : value to be approached
% mode : 'normal', 'inf' (closest lower value) ,'sup'(closest upper value)
% OUTPUT
%ind : index in the input vector of the closest point
% val : value of the vector at the closest point

function [ind, val] = panam_closest( vect, value, mode)

if nargin < 3 || isempty(mode)
    mode = 'normal';
end

% input checking
if ~isvector(vect)
    error('1st input must be a numeric vector');
end

switch mode
    case 'normal'
        % find the closest point
        if value == +Inf
            ind = find(vect == max(vect));
        elseif value == -Inf
            ind = find(vect == min(vect));
        else
            ind = find(abs(vect - value) == min(abs(vect - value)),1);
        end
        ind = ind(1); % handle several indices
        val = vect(ind);
    case 'inf'
        if value == +Inf
            ind = find(vect == max(vect));
        elseif value == -Inf
            error('No inferior value');
        else
            ind = find(abs(vect - value) == min(abs(vect - value)),1);
            if vect(ind) > value
                if ind(1) > 1
                    ind = ind-1;
                else
                    error('No inferior value');
                end
            end
        end
        ind = ind(1);% handle several indices
        val = vect(ind);
    case 'sup'
        if value == +Inf
            error('No superior value');
        elseif value == -Inf
            ind = find(vect == min(vect));
        else
            ind = find(abs(vect - value) == min(abs(vect - value)),1);
            if vect(ind) < value
                if ind(1) < length(vect)
                    ind = ind+1;
                else
                    error('No superior value');
                end
            end
        end
        ind = ind(1);% handle several indices
        val = vect(ind);
end

end

