function setOut = panam_struct2Signal( structIn )

% events
for ii= 1:length(structIn.Events)
    ev{ii} = SignalEvents.empty;
    tmpEv = structIn.Events(ii);
    tmpInfo = containers.Map;
    tmpInfo('ReactionDelay') = tmpEv.ReactionDelay;
    tmpInfo('ResponseTag') = tmpEv.ResponseTag;
    tmpInfo('GoNoGo') = tmpEv.GoNoGo;
    tmpInfo('Pause') = tmpEv.Pause;
    tmpInfo('Sortie') = tmpEv.Sortie;
    ev{ii}(end+1) = SignalEvents(tmpEv.EventsNames{1},...
        tmpEv.EventsTime(1));
    ev{ii}(end+1) = SignalEvents(tmpEv.EventsNames{2},...
        tmpEv.EventsTime(2));
    ev{ii}(end+1) = SignalEvents(tmpEv.EventsNames{3},...
        tmpEv.EventsTime(3),[],tmpInfo);
    infos{ii} = containers.Map;
    infos{ii}('trialName') = structIn.TimeFreqData.TrialName{ii};
    str = strsplit(infos{ii}('trialName'),'_');
    infos{ii}('subject') = str{3};
    infos{ii}('medCondition') = str{4};
    infos{ii}('trialNum') = str2num(str{6});
end

for ii = 1:size(structIn.TimeFreqData.powspctrm,1)
    signalOut(ii) = TimeFreqSignal('data', permute(structIn.TimeFreqData.powspctrm(ii,:,:,:),[4 3 2 1]),...
        'time', structIn.TimeFreqData.time,...
        'freq', structIn.TimeFreqData.freq,...
        'channeltags', structIn.TimeFreqData.label,...
        'infos', infos{ii}, ...
        'events', ev{ii});
end


setOut = SetOfSignals('signals', signalOut,'infos',...
    panam_struct2Map(rmfield(structIn.Infos,{'SubjectCode', 'SubjectNumber', 'MedCondition', 'FileName'})));

end