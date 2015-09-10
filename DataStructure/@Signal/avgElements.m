% Method for class 'Signal' and subclasses
%  avgElements : average the elements of a FreqSignal object
% elements must have the same dimensions
% INPUTS
    % 
% OUTPUT
    % avgSignal : between-elements Signal average



function avgSignal = avgElements(self, varargin)

% make self a column
self = self(:);

% check input
arrayfun(@checkInstance,self);

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
defaultOption.nanmean = 'no'; % by default : nanmean will not be used
defaultOption.subclassFlag = 0;
defaultOption.confint = 'no';
option = setstructfields(defaultOption, varargin);

% check channels : they must be the same for all elements of self
% if not, at least the number of channels must be the same and a warning thrown
if isequal(self.ChannelTags) % same channels for all elements
    channels = self(1).ChannelTags;
else
    channels = arrayfun(@(x) ['chan' num2str(x)],1:len(1),'UniformOutput',0);
    warning('channels do not all have the same name');   
end

% compute average
avgSignal = self(1);
avgSignal.ChannelTags = channels; 
nDims = ndims(self(1).Data);
switch option.nanmean
    case 'yes'
        data  = nanmean(cat(nDims+1,self.Data),nDims+1);
    case 'no'
        data  = mean(cat(nDims+1,self.Data),nDims+1);
end
% confidence interval computed ?
if ischar(option.confint)
    switch lower(option.confint)
        case 'no' % do nothing
        case 'stddev'
            dataSTD  = nanstd(cat(nDims+1,self.Data),[],nDims+1);
            data = permute(cat(nDims+1, data, dataSTD), [1:nDims-1 nDims+1 nDims]);
            avgSignal.DimOrder(end:end+1) = {'confint', avgSignal.DimOrder{end}};
    end
else
   % other cases : struct / cell of options 
end
% affect output
avgSignal.Data = data;
warning('Infos property is set at the first element''s Infos property; compute it separately if necessary');

% check
avgSignal.checkInstance;

% history
if ~option.subclassFlag
    avgSignal.History{end+1,1} = datestr(clock);
    avgSignal.History{end,2} = ...
        'Average the elements of the Signal object';
end

end
