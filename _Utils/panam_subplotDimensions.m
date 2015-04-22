% PANAM_SUBPLOTDIMENSIONS
% Compute the dimensions of subplots according to the total number of
% subplots
% INPUTS
    % nSubplots : total number of subplots
% OUTPUTS
    % horDim : horizontal dimensions (number of lines). = Number of subplots per column
    % vertDim : vertical dimension( number of columns). = Number of subplots per line


function [horDim vertDim] = panam_subplotDimensions( nSubplots )

vertDim = ceil(sqrt(nSubplots));

horDim = ceil(sqrt(nSubplots));

if (horDim-1)*vertDim >= nSubplots
    horDim = horDim - 1;
end

end

