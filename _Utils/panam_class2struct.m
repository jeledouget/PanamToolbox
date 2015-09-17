% PANAM_STRUCT2ARGS
% Transform a structure into a cell of Key-Value pairs arguments
% INPUTS
    % obj : instance of a class
% OUTPUT 
    % struct : equivalent structure

    
function structOut = panam_class2struct(obj)


% affectation
structOut = struct();
fields = fieldnames(obj);
for ii = 1:length(fields)
    structOut.(fields{ii}) = obj.(fields{ii});
end
    
end

