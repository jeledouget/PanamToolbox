function lfp_out = Poly5ToGBMOV_LFP_RealGait_Synchronisation(lfp_in, filename)

%GBMOVSTRUCT_SYNCHRONISATION Remove the trials that are not part of the
%sync file from the Signal_LFP structure

%%  Remove bad trials
[~, ~, trialNums] = xlsread(filename);
trialNums = cell2mat(trialNums(2:end,1));
badTrials = [];
checkTrials = nan(size(trialNums, 1));
for ii = 1:length(lfp_in.Trial)
    if any(trialNums(:,1)==lfp_in.Trial(ii).Raw.TrialNum) % test appartenance de l'essai
        checkTrials(find(trialNums(:,1)==lfp_in.Trial(ii).Raw.TrialNum,1))=1;
    else
        badTrials(end+1) = ii;
    end
end

lfp_out = panam_removeBadTrials(lfp_in, badTrials);

%% check for missing trials
if any(checkTrials ~= 1)
    error('Certains essais n''apparaissent pas');
end

%% history
lfp_out.History{end+1,1} = date;
lfp_out.History{end,2} = ['Synchronisation effectuee depuis' filename];

end

