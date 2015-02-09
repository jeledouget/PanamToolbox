function outputStruct = panam_concatenateProcessedTF(label, varargin)
%PANAM_CONCATENATEPROCESSEDTF Summary of this function goes here
%   Detailed explanation goes here



outputStruct = varargin{1};
outputStruct.TimeFreqData.formerLabels = repmat(outputStruct.TimeFreqData.label,1,length(outputStruct.TimeFreqData.TrialName));
outputStruct.TimeFreqData.label = label;
    


for ii = 2:length(varargin)
    outputStruct.TimeFreqData.powspctrm = cat(1,outputStruct.TimeFreqData.powspctrm, varargin{ii}.TimeFreqData.powspctrm);
    outputStruct.TimeFreqData.blPowspctrm = cat(1,outputStruct.TimeFreqData.blPowspctrm, varargin{ii}.TimeFreqData.blPowspctrm);
    try outputStruct.TimeFreqData.beforeBlCorrPowspctrm = cat(1,outputStruct.TimeFreqData.beforeBlCorrPowspctrm, varargin{ii}.TimeFreqData.beforeBlCorrPowspctrm);end
    outputStruct.TimeFreqData.cumtapcnt = cat(1,outputStruct.TimeFreqData.cumtapcnt, varargin{ii}.TimeFreqData.cumtapcnt);
    outputStruct.TimeFreqData.TrialNum = cat(2,outputStruct.TimeFreqData.TrialNum, varargin{ii}.TimeFreqData.TrialNum);
    outputStruct.TimeFreqData.TrialName = cat(2,outputStruct.TimeFreqData.TrialName, varargin{ii}.TimeFreqData.TrialName);
    outputStruct.Events = cat(2,outputStruct.Events, varargin{ii}.Events);
    outputStruct.Param = cat(2,outputStruct.Param, varargin{ii}.Param);
    outputStruct.TimeFreqData.formerLabels = cat(2,outputStruct.TimeFreqData.formerLabels, repmat(varargin{ii}.TimeFreqData.label,1,length(varargin{ii}.TimeFreqData.TrialName)));
end

outputStruct.History{1,1} = datestr(clock);
outputStruct.History{1,2} = 'Concatenation of the structures : cf Param field';