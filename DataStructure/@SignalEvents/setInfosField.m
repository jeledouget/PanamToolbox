% Method for class 'SignalEvents' and subclasses
%  setInfosField : sets the field of Infos of an Events array with the
%  values given in values
% INPUTS
% OUTPUT
% newEvents : modified SignalEvents vector with unique EventName and
% unique Times for each element


function newEvents = setInfosField(self, field, values)

newEvents = self;

for ii = 1:numel(self)
    if iscell(values)
        newEvents(ii).Infos.(field) = values{ii};
    else
        newEvents(ii).Infos.(field) = values(ii);
    end
end    
    

end
