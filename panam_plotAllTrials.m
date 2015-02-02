function panam_plotAllTrials( inputStruct, field)
%PANAM_PLOTALLTRIALS Summary of this function goes here
%   Detailed explanation goes here

%% inputs

if nargin < 2
    field = 'PreProcessed';
end
colors = jet(6);

%% plot

fprintf('=======Plot Trials=======\n\n\n');
try
    figure('units','normalized','outerposition',[0 0 1 1]);
    nTrials = length(inputStruct.Trials);
    if nTrials < 13
        nH = 4;
        nV = 3;
    elseif nTrials < 17
        nH = 4;
        nV = 4;
    elseif nTrials < 21
        nH = 5;
        nV = 4;
    elseif nTrials < 25
        nH = 6;
        nV = 4;
    elseif nTrials < 31
        nH = 6;
        nV = 5;
    elseif nTrials < 36
        nH = 7;
        nV = 5;
    else
        dims = inputdlg({'Horizontal plots','Vertical plots'},'Enter subplots dimensions');
        nH = str2num(dims{1,1});
        nV = str2num(dims{2,1});
    end
    for jj = 1:nTrials
        h = subplot(nH,nV,jj);
        set(h,'FontSize',5);
        hold on
        for kk = 1:6
            plot(inputStruct.Trials(jj).(field).Time, inputStruct.Trials(jj).(field).Data(kk,:),'color',colors(kk,:));
        end
        title(num2str(inputStruct.Trials(jj).(field).TrialNum),'FontWeight','bold');
    end
    figTitle = strrep(inputStruct.Infos.FileName,'_',' - ');
    [temp1 temp2] = suplabel( figTitle,'t');
    set(temp2,'FontSize',20,'FontWeight','bold');
    legend(cellfun(@(x) strrep(x,'_',' - '),inputStruct.Trials(1).(field).Tag,'UniformOutput',0),'Position',[0.02 0.5 0.05 0.2]);
catch
    disp(['problem with ' inputStruct.Infos.FileName]);
end

fprintf('\n\n\n=======Finish Check Trials=======\n\n\n\n');



end

