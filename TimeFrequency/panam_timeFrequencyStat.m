function outputStruct = panam_timeFrequencyStat( inputStruct)

%PANAM_TIMEFREQUENCYSTAT Perform statistical test activation vs. baseline
%for Processed Time-Frequency Panam structure

nFreq = size(inputStruct.TimeFreqData.powspctrm,3);
nTimes = size(inputStruct.TimeFreqData.powspctrm,4);
avgBL = mean(inputStruct.TimeFreqData.blPowspctrm,4);
hMask = nan(1,nFreq,nTimes);
pMask = nan(1,nFreq,nTimes);

for ii=1:nFreq
    for jj=1:nTimes
        try
            [hMask(1,ii,jj) pMask(1,ii,jj)] = ttest(squeeze(inputStruct.TimeFreqData.powspctrm(:,1,ii,jj)), squeeze(avgBL(:,1,ii)));
        catch
            hMask(1,ii,jj) = nan;
            pMask(1,ii,jj) = nan;
        end
    end
end

temp = reshape(pMask,1,[]);
temp = sort(temp);
[~, corr_p] = fdr_bh(temp,0.05);
hMaskCorr = (pMask < corr_p);

outputStruct = inputStruct;
outputStruct.TimeFreqData.stat.pMask = pMask;
outputStruct.TimeFreqData.stat.hMask = hMask;
outputStruct.TimeFreqData.stat.hMaskCorr = hMaskCorr;
outputStruct.History{end+1,1} = datestr(clock);
outputStruct.History{end,2} = 'Statistical mask computation with panam_timeFrequencyStat';

end

