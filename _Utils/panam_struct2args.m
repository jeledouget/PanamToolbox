% PANAM_STRUCT2ARGS
% Transform a structure into a cell of Key-Value pairs arguments
% INPUTS
    % struct : input structure
% OUTPUT 
    % kvPairs : Key-Value pairs arguments cell

    
function kvPairs = panam_struct2args(struct)


% check input
if ~isstruct(struct) || isempty(struct)
    error('input must be a non-empty structure');
end

% affectation
fields = fieldnames(struct);
for ii = 1:length(fields)
    kvPairs{2*ii - 1} = fields{ii};
    kvPairs{2*ii} = struct.(fields{ii});
end
    

end

