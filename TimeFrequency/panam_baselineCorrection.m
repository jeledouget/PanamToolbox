function timeFreqOut = panam_baselineCorrection(timeFreqIn, corrType )
%PANAM_BASELINECORRECTION computes the baseline correction in Processed
%PANAM time frequency structures

% INPUTS
% timeFreqIn : time frequency structure (FieldTrip)
% corrType : baseline correction type -> DB, ZSCORE, RELATIVECHANGE

% OUTPUTS
% timeFreqOut : modified timeFrequency structure (FieldTrip)

timeFreqOut = timeFreqIn;
switch corrType
    case 'DB'
        meanBL = nanmean(timeFreqIn.blPowspctrm,4);
        timeFreqOut.beforeBlCorrPowspctrm = timeFreqIn.powspctrm;
        timeFreqOut.blCorr = 'DB';
        timeFreqOut.powspctrm = 10*log10(timeFreqIn.powspctrm ./ repmat(meanBL, [1 1 1 length(timeFreqIn.time)]));
    case 'ZSCORE'
        meanBL = nanmean(timeFreqIn.blPowspctrm,4);
        stdDevBL = nanstd(timeFreqIn.blPowspctrm,0,4);
        timeFreqOut.beforeBlCorrPowspctrm = timeFreqIn.powspctrm;
        timeFreqOut.blCorr = 'ZSCORE';
        timeFreqOut.powspctrm = (timeFreqIn.powspctrm - repmat(meanBL, [1 1 1 length(timeFreqIn.time)])) ./ ...
            repmat(stdDevBL, [1 1 1 length(timeFreqIn.time)]);
    case 'RELATIVECHANGE'
        meanBL = nanmean(timeFreqIn.blPowspctrm,4);
        timeFreqOut.beforeBlCorrPowspctrm = timeFreqIn.powspctrm;
        timeFreqOut.blCorr = 'RELATIVECHANGE';
        timeFreqOut.powspctrm = (timeFreqIn.powspctrm - repmat(meanBL, [1 1 1 length(timeFreqIn.time)])) ./ ...
            repmat(meanBL, [1 1 1 length(timeFreqIn.time)]);
end
end

