function outputStruct = panam_concatenateProcessedTF(label, varargin)
%PANAM_CONCATENATEPROCESSEDTF Summary of this function goes here
%   Detailed explanation goes here


for ii = 1:length(varargin)
    varargin{ii}.TimeFreqData = panam_baselineCorrection(varargin{ii}.TimeFreqData,'DB');
end
outputStruct = varargin{1};
outputStruct.TimeFreqData.label = label;
outputStruct.TimeFreqData.blCorr = 'DB';

for ii = 2:length(varargin)
    outputStruct.TimeFreqData.powspctrm = cat(1,outputStruct.TimeFreqData.powspctrm, varargin{ii}.TimeFreqData.powspctrm);
    outputStruct.TimeFreqData.blPowspctrm = cat(1,outputStruct.TimeFreqData.blPowspctrm, varargin{ii}.TimeFreqData.blPowspctrm);
    outputStruct.TimeFreqData.beforeBlCorrPowspctrm = cat(1,outputStruct.TimeFreqData.beforeBlCorrPowspctrm, varargin{ii}.TimeFreqData.beforeBlCorrPowspctrm);
    outputStruct.TimeFreqData.cumtapcnt = cat(1,outputStruct.TimeFreqData.cumtapcnt, varargin{ii}.TimeFreqData.cumtapcnt);
    outputStruct.TimeFreqData.TrialNum = cat(2,outputStruct.TimeFreqData.TrialNum, varargin{ii}.TimeFreqData.TrialNum);
    outputStruct.TimeFreqData.TrialName = cat(2,outputStruct.TimeFreqData.TrialName, varargin{ii}.TimeFreqData.TrialName);
    outputStruct.Events = cat(2,outputStruct.Events, varargin{ii}.Events);
    outputStruct.Param = cat(2,outputStruct.Param, varargin{ii}.Param);
end

outputStruct.History{1,1} = datestr(clock);
outputStruct.History{1,2} = 'Concatenation of the structures : cf Param field';