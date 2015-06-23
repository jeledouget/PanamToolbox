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

% plot Bad Trials
figure('units','normalized','outerposition',[0 0 1 1]);
[nH, nV] = panam_subplotDimensions(numel(indicesBad));
for ii = 1:numel(indicesBad)
    subplot(nH, nV, ii)
    signalIn(indicesBad(ii)).plot('events','all');
    title(num2str(indicesBad(ii)));
end
[~, temp2] = suplabel( 'Bad Trials','t');
set(temp2,'FontSize',20,'FontWeight','bold');

% plot Good Trials
figure('units','normalized','outerposition',[0 0 1 1]);
[nH, nV] = panam_subplotDimensions(numel(indicesGood));
for ii = 1:numel(indicesGood)
    subplot(nH, nV, ii)
    signalIn(indicesGood(ii)).plot('events','all');
    title(num2str(indicesGood(ii)));
end
[~, temp2] = suplabel( 'Good Trials','t');
set(temp2,'FontSize',20,'FontWeight','bold');

[indicesBad, indicesGood] = selectGoodTrials(indicesGood, indicesBad);


end

