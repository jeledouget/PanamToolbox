% APPLYTOELEMENTS
% apply a function to each element of the Signals property in a
% SetOfSignals property, with variable arguments


function output = applyToElements(self, func, elementArgs,  varargin)

% element-specific arguments
if isa(elementArgs, 'function_handle')
    elementArgs = arrayfun(elementArgs, self, 'UniformOutput',0);
else


% compute and store result of function on each element
tmp = cell(size(self.Signals));
for ii = 1:numel(self.Signals)
    tmp{ii} = func(self.Signals(ii),elementArgs{ii}, varargin{:});
end

% affect output : if tmp is full of Signals, then return a set
% otherwise return Signals
if isa(tmp{1},'Signal')
    output = self;
    dims = size(self.Signals);
    output.Signals = reshape([tmp{:}], dims);
else
    output = tmp;
end

end

