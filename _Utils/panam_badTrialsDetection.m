function [indicesBad, indicesGood] = panam_badTrialsDetection( signalIn, threshold)

%PANAM_GNG_BADTRIALSDETECTION

signalIn = signalIn(:);

% param
indicesBad = [];
if nargin < 2 || isempty(threshold)
    threshold = 5;
end

% each trial
nTrials = length(signalIn);
for ii = 1:nTrials
    trial{ii} = signalIn(ii).Data';
    maxTrial{ii} = max(abs(max(trial{ii},[],2)), abs(min(trial{ii},[],2)));
end
stdDev = std([trial{:}],0,2);
indicesBad = find(cellfun(@(x) any(x > threshold * stdDev), maxTrial));
indicesGood = setdiff(1:nTrials, indicesBad);


hBad = signalIn(indicesBad).plot('channels', 'list', 'signals', 'grid', 'uniqueAxes',1);
set(gcf, 'Name', 'Bad Trials ?');
for i = 1:numel(hBad)
   title(hBad(i), num2str(indicesBad(i))); 
end

hGood = signalIn(indicesGood).plot('channels', 'list', 'signals', 'grid', 'uniqueAxes',1);
set(gcf, 'Name', 'Good Trials ?');
for i = 1:numel(hGood)
   title(hGood(i), num2str(indicesGood(i))); 
end


[indicesBad, indicesGood] = selectGoodTrials(indicesGood, indicesBad);


end

