freqTest = FreqSignal('data',rand(31,5), 'freq', 0:2:60);
sampledTest = SampledTimeSignal('data',rand(201,5), 'fs', 200);
events = SignalEvents('sound trigger', [0.1 0.6]);
sampledTest.Events('GO') = events;
timefreqTest = TimeFreqSignal('data', rand(201,31,5), 'time', sort(rand(1,201)), 'freq', 0:2:60, 'events', sampledTest.Events);
for ii = 1:20
    signals(ii) = SampledTimeSignal('data',rand(201,5), 'fs', 100);
end
setTest  = SetOfSignals('signals', signals);


clear signals ii
clc
