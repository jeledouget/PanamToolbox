% APPLYTOELEMENTS
% apply a function to each element of the Signals property in a
% SetOfSignals property


function output = applyToElements(self, func,  varargin)

% compute and store result of function on each element
tmp = arrayfun(@(x) func(x,varargin{:}),self.Signals, 'UniformOutput',0);

% affect output : if tmp is full of Signals, then return a set
% otherwise return Signals
if isa(tmp{1,1},'Signal')
    output = self;
    dims = size(self.Signals);
    output.Signals = reshape([tmp{:}], dims);
else
    output = tmp;
end

end

