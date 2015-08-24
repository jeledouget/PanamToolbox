% PANAM_INTERPMATRIX
% Create a matrix of interpolation that does not take data into acconut,
% only the original and the destination time ( or freq, etc) vectors
% INPUTS
% origin : increasing numeric vector
% dest : increasing numeric vector
% varargin contains options for the type of interpolation
% OUTPUT
% interpMatrix : sparse matrix that maps origin onto destination

function interpMatrix = panam_interpMatrix(origin, dest, varargin)

% check
if ~isvector(origin) || ~isvector(dest)
    error('origin and dest inputs must be vectors');
elseif ~isnumeric(origin) || ~isnumeric(dest)
    error('origin and dest inputs must be of numeric type');
elseif ~issorted(origin) || ~issorted(dest)
    error('origin and dest inputs must be sorted in increasing order');
end

% args & options
if ~isempty(varargin)
    if ischar(varargin{1}) % kvPairs
        varargin = panam_args2struct(varargin);
    else % structure
        varargin = varargin{1};
    end
else
    varargin = [];
end
defaultOption.type = 'linear'; % other option : nearest
defaultOption.extrap = 0; % by default : no extrapolation
option = setstructfields(defaultOption, varargin);

% compute matrix
switch option.type
    case 'nearest'
        defaultOption.tol = 1e-3; % default tolerance before considering extrapolation : 1e-3
        option = setstructfields(defaultOption, varargin);
        switch option.extrap
            case 0
                interpMatrix = spalloc(numel(origin),numel(dest),numel(dest));
                for i = 1:numel(dest)
                    if dest(i) < origin(1)-option.tol || dest(i) > origin(end)+option.tol
                        interpMatrix(1,i) = nan;
                    else
                        a = panam_closest(origin, dest(i));
                        interpMatrix(a,i) = 1;
                    end
                end
            case 1
                interpMatrix = spalloc(numel(origin),numel(dest),numel(dest));
                for i = 1:numel(dest)
                    if i < numel(dest) && dest(i+1) <= origin(1)
                        interpMatrix(1,i) = nan;
                    elseif i > 1 && dest(i-1) >= origin(end)
                        interpMatrix(1,i) = nan;
                    else
                        a = panam_closest(origin, dest(i));
                        interpMatrix(a,i) = 1;
                    end
                end
            case 2
                interpMatrix = spalloc(numel(origin),numel(dest),numel(dest));
                for i = 1:numel(dest)
                    a = panam_closest(origin, dest(i));
                    interpMatrix(a,i) = 1;
                end
        end
    case 'linear' % default
        if length(origin) < 2
            error('to do linear interpolation, at least 2 elements must be present in the origin vector');
        end
        switch option.extrap
            case 0
                interpMatrix = spalloc(numel(origin),numel(dest),2*numel(dest));
                for i = 1:numel(dest)
                    try
                        [low, val_low] = panam_closest(origin, dest(i), 'inf');
                        [high, val_high] = panam_closest(origin, dest(i), 'sup');
                        dist = val_high - val_low;
                        if dist == 0 % low = high
                            interpMatrix(low,i) = 1;
                        else
                            coeff_high = (dest(i) - val_low) / dist;
                            coeff_low = 1 - coeff_high;
                            interpMatrix(low,i) = coeff_low;
                            interpMatrix(high,i) = coeff_high;
                        end
                    catch % one of the values cannot be set
                        interpMatrix(1,i) = nan;
                    end
                end
            case 1
                interpMatrix = spalloc(numel(origin),numel(dest),2*numel(dest));
                for i = 1:numel(dest)
                    try
                        [low, val_low] = panam_closest(origin, dest(i), 'inf');
                        [high, val_high] = panam_closest(origin, dest(i), 'sup');
                        dist = val_high - val_low;
                        if dist == 0 % low = high
                            interpMatrix(low,i) = 1;
                        else
                            coeff_high = (dest(i) - val_low) / dist;
                            coeff_low = 1 - coeff_high;
                            interpMatrix(low,i) = coeff_low;
                            interpMatrix(high,i) = coeff_high;
                        end
                    catch % one of the values cannot be set
                        if i < numel(dest) && dest(i) < origin(1) && dest(i+1) >= origin(1)
                            low = 1;
                            high = 2;
                            val_low = origin(low);
                            val_high = origin(high);
                            dist = val_high - val_low;
                            coeff_high = (dest(i) - val_low) / dist;
                            coeff_low = 1 - coeff_high;
                            interpMatrix(low,i) = coeff_low;
                            interpMatrix(high,i) = coeff_high;
                        elseif i > 1 && dest(i) > origin(end) && dest(i-1) <= origin(end)
                            low = numel(origin) - 1;
                            high = numel(origin);
                            val_low = origin(low);
                            val_high = origin(high);
                            dist = val_high - val_low;
                            coeff_high = (dest(i) - val_low) / dist;
                            coeff_low = 1 - coeff_high;
                            interpMatrix(low,i) = coeff_low;
                            interpMatrix(high,i) = coeff_high;
                        else
                            interpMatrix(1,i) = nan;
                        end
                    end
                end
            case 2
                interpMatrix = spalloc(numel(origin),numel(dest),2*numel(dest));
                for i = 1:numel(dest)
                    try
                        [low, val_low] = panam_closest(origin, dest(i), 'inf');
                        [high, val_high] = panam_closest(origin, dest(i), 'sup');
                        dist = val_high - val_low;
                        if dist == 0 % low = high
                            interpMatrix(low,i) = 1;
                        else
                            coeff_high = (dest(i) - val_low) / dist;
                            coeff_low = 1 - coeff_high;
                            interpMatrix(low,i) = coeff_low;
                            interpMatrix(high,i) = coeff_high;
                        end
                    catch % one of the values cannot be set
                        if dest(i) < origin(1)
                            low = 1;
                            high = 2;
                            val_low = origin(low);
                            val_high = origin(high);
                            dist = val_high - val_low;
                            coeff_high = (dest(i) - val_low) / dist;
                            coeff_low = 1 - coeff_high;
                            interpMatrix(low,i) = coeff_low;
                            interpMatrix(high,i) = coeff_high;
                        elseif dest(i) > origin(end)
                            low = numel(origin) - 1;
                            high = numel(origin);
                            val_low = origin(low);
                            val_high = origin(high);
                            dist = val_high - val_low;
                            coeff_high = (dest(i) - val_low) / dist;
                            coeff_low = 1 - coeff_high;
                            interpMatrix(low,i) = coeff_low;
                            interpMatrix(high,i) = coeff_high;
                        end
                    end
                end
        end
       
        
end

