% APPLY
% apply a function to the Signals property matrix in a
% SetOfSignals property


function output = apply(self, func,  varargin)

% compute and store result of function on each element
tmp = func(self.Signals,varargin{:});

% affect output : if tmp is full of Signals, then return a set
% otherwise return Signals
if isa(tmp,'Signal')
    output = self;
    output.Signals = tmp;
else
    output = tmp;
end

end

