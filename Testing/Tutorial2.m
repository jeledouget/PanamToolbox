
%% Write script with Panam_Toolbox

%% Generate a Signal array

clear s

time = linspace(0,100,100001);
for i = 1:5
    f = round(10*rand(1));
    phase = 2*pi*rand(1);
    noise = 0.5*(rand(numel(time),1)-0.5);
    data = cos(2*pi*f*time'+ phase) + noise;
    s(i) = TimeSignal('data', data, 'time', time);
end
s.plot('signals', 'grid');

%% Filter the signal

% 1st try
try 
    s.lowPassFilter(5).plot('signals', 'grid');
catch 
    disp('error in 1st try');
end

% filters : methods for sSampledTimeSignal
s = s.toSampledTimeSignal;
s.lowPassFilter(5).plot('signals', 'grid');
class(s)
s.lowPassFilter(5).plot('signals', 'grid');


%% Add events

for i = 1:5
   event =SignalEvents('GO', rand(1));
   s(i).Events = event;
end
s.plot('signals', 'grid', 'colormap', 'hsv');


%% Spectrum

sp = s.psd();
sp.plot;
sp.plot('xaxis', [0 30]);

%% Time-Freq

tf = s.tfPsd;
for i = 1:5
    tf(i).plot;
end






