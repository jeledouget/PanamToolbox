function setOut = panam_struct2Signal( structIn )

% events
for ii= 1:length(structIn.Events)
    ev{ii} = SignalEvents.empty;
    tmpEv = structIn.Events(ii);
    tmpInfo = containers.Map;
    tmpInfo('ReactionDelay') = tmpEv.ReactionDelay;
    tmpInfo('ResponseTag') = tmpEv.ReponseTag;
    tmpInfo('GoNoGo') = tmpEv.GoNoGo;
    tmpInfo('Pause') = tmpEv.Pause;
    tmpInfo('Sortie') = tmpEv.Sortie;
    ev{ii}(end+1) = SignalEvents(tmpEv.EventsNames{1},...
        tmpEv.EventsTime(1));
    ev{ii}(end+1) = SignalEvents(tmpEv.EventsNames{1},...
        tmpEv.EventsTime(1));
    ev{ii}(end+1) = SignalEvents(tmpEv.EventsNames{1},...
        tmpEv.EventsTime(1),[],tmpInfo);
end

for ii = 1:size(structIn.TimeFreqData.powspctrm,1)
    signalOut(ii) = TimeFreqSignal('data', permute(structIn.TimeFreqData.powspctrm(ii,:,:,:),[4 3 2 1],...
        'time', structIn.TimeFreqData.time,...
        'freq', structIn.TimeFreqData.freq,...
        'channeltags', structIn.TimeFreqData.label,
        'events', ev{ii});
end


setOut = SetOfSignals('signals', signalOut,'infos', panam_struct2Map(structIn.Infos));

end