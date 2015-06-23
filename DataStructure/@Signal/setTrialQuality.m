% Method for class 'Signal' and subclasses
%  setTrialsQuality : set a quality field in Info of a Signal
% INPUTS
    % 
% OUTPUT
    % markedSignal : sorted Signal elements


function markedSignal = setTrialQuality(self, quality)

markedSignal = self;

%
for ii = 1:numel(self)
    markedSignal(ii).Infos.trialQuality = quality;
end


    

end
