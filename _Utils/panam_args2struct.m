% PANAM_ARGS2STRUCT
% Transform a cell of Key-Value pairs arguments into a structure with
% fieldnames as Keys and field values as Values
% INPUTS
    % kvPairs : Key-Value pairs arguments cell or list
% OUTPUT
    % struct : output structure 

function structOut = panam_args2struct( kvPairs)

structOut = struct();
kvPairs = kvPairs(:);

% check input
if ~iscell(kvPairs) || mod(length(kvPairs), 2) || ...
        ~iscellstr(kvPairs(1:2:end))
    error('Key-Value Pairs input must be a cell vector with char input for keys');
end

% affectation
for ii = 1:2:length(kvPairs)
    structOut.(kvPairs{ii}) = kvPairs{ii+1};
end


end

