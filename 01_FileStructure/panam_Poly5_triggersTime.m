function listTriggers = panam_Poly5_triggersTime(inputFile)

%PANAM_SORTTRIGGERS Identify triggers from poly5 file and return the time
%difference between them

% read file
[infos data] = tms_read_to_edf_struct(inputFile);
fs = infos.fs;

% compute samples and times
data = data(1,:); % trigger vector
temp = find(data > median(data)); % trigger samples
temp2 = temp(2:end) - temp(1:end-1) ; % 
indices = find(temp2 > 1 ) + 1; % non-consecutive samples
triggerSamples = [temp(1) temp(indices)]; % get 1st sample of each trigger
diffTimes = 1/fs * (triggerSamples(2:end) - triggerSamples(1:end-1)); % compute time difference between successive triggers

% output
listTriggers.startDate = infos.startdate;
listTriggers.startTime = infos.starttime;
listTriggers.triggerSamples = triggerSamples;
listTriggers.triggerTimes = [0 diffTimes];
end

