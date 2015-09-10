% Method for class 'TimeSignal' and subclasses
%  adjustTime : for muti-elements TimeSignal, make it that all elements
%  have the same Time axis. Useful before averaging for example
% INPUTS
% OUTPUT



function newSignal = correction(self, corrType, varargin)

% copy of the object
newSignal = self;

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

switch lower(corrType)
    case 'zscore'
        
    case 'db'
        
    case {'relativechange', 'relchange'}
        
end

% history
for ii = 1:numel(newSignal)
    newSignal(ii).History{end+1,1} = datestr(clock);
    newSignal(ii).History{end,2} = ...
        ['Correct the signal'];
end
end
