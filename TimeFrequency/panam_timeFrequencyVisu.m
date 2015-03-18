function h = panam_timeFrequencyVisu(inputStruct, blCorr, stat, freqBand)
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
cfg = [];


%% test : log-transform (-> test de normalite a effectuer ? Fischer ?)

% inputStruct.TimeFreqData.powspctrm = log(inputStruct.TimeFreqData.powspctrm);
% inputStruct.TimeFreqData.blPowspctrm = log(inputStruct.TimeFreqData.blPowspctrm);
% try inputStruct.TimeFreqData.beforeBlCorrPowspctrm = log(inputStruct.TimeFreqData.beforeBlCorrPowspctrm);end

%% baseline correction
if nargin > 1 % blCorrection required
    if isempty(blCorr)
        blCorr = 'none';
    end
    if ~strcmpi(inputStruct.TimeFreqData.blCorr, blCorr)
        if ~strcmpi(inputStruct.TimeFreqData.blCorr, 'NoBlCorrection')
            inputStruct.TimeFreqData.powspctrm = inputStruct.TimeFreqData.beforeBlCorrPowspctrm;
        end
        inputStruct.TimeFreqData = panam_baselineCorrection(inputStruct.TimeFreqData,blCorr);
        inputStruct.TimeFreqData.blCorr = blCorr;
    end
end

%% freqBand
if nargin > 3
    if ~isnumeric(freqBand) || length(freqBand) ~= 2 || freqBand(1) > freqBand(2)
        error('FreqBand uncorrectly specified : must be a vector [minFreq maxFreq]');
    end
    cfg.ylim = freqBand;
else
    cfg.ylim = 'maxmin';
end


%% stat view
if nargin > 2  && ~isempty(stat)% stat view
    if ~isnumeric(stat) || stat < 0
        warning('Stat mask not appearing');
    else
        for ii=1:size(inputStruct.TimeFreqData.powspctrm,1)
            for kk = 1:size(inputStruct.TimeFreqData.powspctrm,2)
                inputStruct.TimeFreqData.powspctrm(ii,kk,:,:) = squeeze(inputStruct.TimeFreqData.stat(stat).hMaskCorr(kk,:,:)) .* squeeze(inputStruct.TimeFreqData.powspctrm(ii,kk,:,:));
                if strcmp(inputStruct.TimeFreqData.stat(stat).method,'ttest_cluster');
                    [tempFreq, tempTime] = find(~isnan(squeeze(inputStruct.TimeFreqData.stat(stat).hMaskCorr(1,:,:))));
                    cfg.xlim = inputStruct.TimeFreqData.time([min(tempTime) max(tempTime)]);
                end
                if isnumeric(cfg.ylim)
                    firstFreqIndex = nearest(inputStruct.TimeFreqData.freq, cfg.ylim(1));
                    lastFreqIndex = nearest(inputStruct.TimeFreqData.freq, cfg.ylim(2));
                else % 'maxmin' freqband
                    firstFreqIndex = 1;
                    lastFreqIndex = length(inputStruct.TimeFreqData.freq);
                end
                if all(all(inputStruct.TimeFreqData.powspctrm(ii,kk,:,firstFreqIndex:lastFreqIndex)==0))
                    inputStruct.TimeFreqData.powspctrm(ii,kk,firstFreqIndex,1) = 1; % avoid all zero values for future visualization
                end
            end
        end
    end
end


%% plots
figure;
for ii = 1:length(inputStruct.TimeFreqData.label)
    tempLegend = {};
    cfg.channel = inputStruct.TimeFreqData.label(ii);
    h{ii} = subplot(nSPV, nSPH, ii);
    ft_singleplotTFR(cfg, inputStruct.TimeFreqData);
    colormap(jet(256));
    tempTitle = strrep(cfg.channel{1},'_', ', ');
    tempTitle = strrep(tempTitle,':', ': ');
    tempTitle2 = strrep(inputStruct.TimeFreqData.blCorr,'Bl',' Baseline ');
    tempTitle = [tempTitle ' (' tempTitle2 ')'];
    title(tempTitle,'FontSize', 20, 'FontName','New Century Schoolbook');
    xlabel({'Time','[s]'}, 'FontSize', 15, 'FontName','New Century Schoolbook');
    xlab = get(h{ii},'xlabel');
    set(xlab,'Position',get(xlab,'Position') - [0 .2 0]);
    ylabel({'Frequency','[Hz]'}, 'FontSize', 15, 'FontName','New Century Schoolbook');
    hold off
    hold all
    colorCount = 1;
    set(h{ii}, 'FontSize', 15, 'FontName','New Century Schoolbook', 'OuterPosition',[mod(ii-1,nSPH)/nSPH (nSPV-ceil(ii/nSPH))/nSPV 1/nSPH 1/nSPV]);
    if ~isempty(inputStruct.Events)
        for jj = 1:length(inputStruct.Events(1).EventsNames)
            event = nanmean(arrayfun(@(x) x.EventsTime(jj),inputStruct.Events));
            if all(strcmpi({inputStruct.Param.marker},inputStruct.Events(1).EventsNames{jj}))
                % normally event is equal to 0
                plot([event event],[firstFreq lastFreq],'linewidth',3,'color','r');
                tempLegend{end+1} = inputStruct.Events(1).EventsNames{jj};
            elseif any(strcmpi({inputStruct.Param.marker},inputStruct.Events(1).EventsNames{jj}))
                error('concatenated structures must be time-locked to the same marker to be visualizable');
            elseif event > startTime && event < endTime
                plot([event event],[firstFreq lastFreq],'linewidth',2,'color',liste_colors{1+mod(colorCount-1,length(liste_colors))});
                colorCount = colorCount + 1;
                tempLegend{end+1} = inputStruct.Events(1).EventsNames{jj};
            end
        end
        hleg = legend(tempLegend);
        set(hleg, 'Location','NorthWest');
    else
        plot([0 0],[firstFreq lastFreq],'linewidth',3,'color','r');
        hleg = legend({'Trigger'});
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

