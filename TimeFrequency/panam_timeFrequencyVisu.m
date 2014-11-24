function panam_timeFrequencyVisu(inputStruct, blCorr)
%PANAM_TIMEFREQUENCYVISU Visualization tool for processed Panam TimeFreq
%Data
% (result from panam_timeFrequencyProcess)


%% params
liste_colors = {'m','b','k','c',[0.5 0.5 0.5],'y'};
[nSPV,nSPH] = subplot_dimensions(length(inputStruct.TimeFreqData.label));
startTime = inputStruct.TimeFreqData.time(1);
endTime = inputStruct.TimeFreqData.time(end);
firstFreq = min(inputStruct.TimeFreqData.freq);
lastFreq = max(inputStruct.TimeFreqData.freq);

%% test : log-transform (-> test de normalite a effectuer ? Fischer ?)

% inputStruct.TimeFreqData.powspctrm = log(inputStruct.TimeFreqData.powspctrm);
% inputStruct.TimeFreqData.blPowspctrm = log(inputStruct.TimeFreqData.blPowspctrm);
% try inputStruct.TimeFreqData.beforeBlCorrPowspctrm = log(inputStruct.TimeFreqData.beforeBlCorrPowspctrm);end

%% baseline correction
if nargin > 1 % blCorrection required
    if ~strcmpi(inputStruct.TimeFreqData.blCorr, blCorr) && ...
            ~strcmpi(inputStruct.TimeFreqData.blCorr, 'NoBlCorrection')
        inputStruct.TimeFreqData.powspctrm = inputStruct.TimeFreqData.beforeBlCorrPowspctrm;
        inputStruct.TimeFreqData = panam_baselineCorrection(inputStruct.TimeFreqData,blCorr);
        inputStruct.TimeFreqData.blCorr = blCorr;
    end
end


%% plots
figure;
for ii = 1:length(inputStruct.TimeFreqData.label)
    tempLegend = {};
    cfg.channel = inputStruct.TimeFreqData.label(ii);
    h = subplot(nSPV, nSPH, ii);
    ft_singleplotTFR(cfg, inputStruct.TimeFreqData);
    tempTitle = strrep(cfg.channel{1},'_', ', ');
    tempTitle = strrep(tempTitle,':', ': ');
    tempTitle2 = strrep(inputStruct.TimeFreqData.blCorr,'Bl',' Baseline ');
    tempTitle = [tempTitle ' (' tempTitle2 ')'];
    title(tempTitle,'FontSize', 20, 'FontName','New Century Schoolbook');
    xlabel({'Time','[s]'}, 'FontSize', 15, 'FontName','New Century Schoolbook');
    xlab = get(h,'xlabel');
    set(xlab,'Position',get(xlab,'Position') - [0 .2 0]);
    ylabel({'Frequency','[Hz]'}, 'FontSize', 15, 'FontName','New Century Schoolbook');
    hold off
    hold all
    colorCount = 1;
    set(h, 'FontSize', 15, 'FontName','New Century Schoolbook', 'OuterPosition',[mod(ii-1,nSPH)/nSPH (nSPV-ceil(ii/nSPH))/nSPV 1/nSPH 1/nSPV]);
    if ~isempty(inputStruct.Events)
        for jj = 1:length(inputStruct.Events(1).EventsNames)
            event = nanmean(arrayfun(@(x) x.EventsTime(jj),inputStruct.Events));
            if strcmpi(inputStruct.Param.marker,inputStruct.Events(1).EventsNames{jj})
                % normally event is equal to 0
                plot([event event],[firstFreq lastFreq],'linewidth',3,'color','r');
                tempLegend{end+1} = inputStruct.Events(1).EventsNames{jj};
            elseif event > startTime && event < endTime
                plot([event event],[firstFreq lastFreq],'linewidth',2,'color',liste_colors{colorCount});
                colorCount = colorCount + 1;
                tempLegend{end+1} = inputStruct.Events(1).EventsNames{jj};
            end
        end
        hleg = legend(tempLegend);
        set(hleg, 'Location','NorthWest');
    end
end


end



function [nSPV,nSPH] = subplot_dimensions(n)
switch n
    case 1
        nSPV = 1;
        nSPH = 1;
    case 2
        nSPV = 1;
        nSPH = 2;
    case 3
        nSPV = 1;
        nSPH = 3;
    case 4
        nSPV = 2;
        nSPH = 2;
    case {5,6}
        nSPV = 2;
        nSPH = 3;
    case {7,8,9}
        nSPV = 3;
        nSPH = 3;
    otherwise
        error('no more than 9 subplots are possible');
end
end

