% Method for class 'Signal' and subclasses
%  avgElements : average the elements of a FreqSignal object
% elements must have the same dimensions
% INPUTS
    % 
% OUTPUT
    % avgSignal : between-elements Signal average



function avgSignal = avgElements(self, subclassFlag)

% subclass
if nargin <2 || isempty(subclassFlag)
    subclassFlag = 0;
end

% make self a column
self = self(:);

% check input
arrayfun(@checkInstance,self);

% check dimensions
sizes = arrayfun(@(x) size(x.Data), self, 'UniformOutput',0);
if ~isequal(sizes{:})
    error('to be averaged, elements of self must be of the same dimensions');
end

% check channels : they must be the same for all elements of self
% if not, at least the number of channels must be the same and a warning thrown
if isequal(self.ChannelTags) % same channels for all elements
    channels = self(1).ChannelTags;
else
    channels = arrayfun(@(x) ['chan' num2str(x)],1:len(1),'UniformOutput',0);
    warning('channels do not all have the same name');
    
end

% compute average of elements
avgSignal = self(1);
avgSignal.ChannelTags = channels;


% assign output
avgSignal = self(1);
nDims = ndims(self(1).Data);
data  = mean(cat(nDims+1,self.Data),nDims+1);
avgSignal.Data = data;

% check
avgSignal.checkInstance;

% history
if ~subclassFlag
    avgSignal.History{end+1,1} = datestr(clock);
    avgSignal.History{end,2} = ...
        'Average the elements of the Signal object';
end

end