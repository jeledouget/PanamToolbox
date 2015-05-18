events = SignalEvents('GO', [0.1 0.6]);
for ii = 1:5
    freqTest(ii) = FreqSignal('data',rand(31,5), 'freq', 0:2:60, 'freqmarkers', [FreqMarkers('peakAlpha',11), FreqMarkers('peakBeta',25)]);
sampledTest(ii) = SampledTimeSignal('data',rand(201,5), 'fs', 200);
sampledTest(ii).Events = events;
timefreqTest(ii) = TimeFreqSignal('data', rand(201,31,5), 'time', sort(rand(1,201)), 'freq', 0:2:60, 'events', events,...
    'freqmarkers', [FreqMarkers('peakAlpha',11), FreqMarkers('peakBeta',25)]);
end
for ii = 1:20
    signals(ii) = SampledTimeSignal('data',rand(201,5), 'fs', 100);
end
setTest  = SetOfSignals('signals', signals);


clear signals ii
clc
