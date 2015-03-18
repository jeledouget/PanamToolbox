function outputStruct = panam_timeFreq_ExtractFeatures2(inputStruct)

for i = 1:length(inputStruct.TimeFreqData.TrialNum)
    outputStruct.Trial(i).TrialName = inputStruct.TimeFreqData.TrialName(i);
    outputStruct.Trial(i).TrialNum = inputStruct.TimeFreqData.TrialNum(i);
    
    %% Time Events / Samples
    try
        tr = find(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(1)) == min(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(1))));
        t0 = find(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(2)) == min(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(2))));
        %     h0 = find(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(3)) == min(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(3))));
        toff1 = find(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(4)) == min(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(4))));
        fc1 = find(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(5)) == min(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(5))));
        fo2 = find(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(6)) == min(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(6))));
        fc2 = find(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(7)) == min(abs(inputStruct.TimeFreqData.time - inputStruct.Events(i).EventsTime(7))));
        
        
        %% theta
        theta  =[2 6];%Hz
        freqTheta(1) = find(abs(inputStruct.TimeFreqData.freq - theta(1)) == min(abs(inputStruct.TimeFreqData.freq - theta(1))));
        freqTheta(2) = find(abs(inputStruct.TimeFreqData.freq - theta(2)) == min(abs(inputStruct.TimeFreqData.freq - theta(2))));
        
        outputStruct.Trial(i).thetaBL = mean(mean(inputStruct.TimeFreqData.blPowspctrm(i,1,freqTheta(1):freqTheta(2),:),4),3);
        outputStruct.Trial(i).theta_tr_t0_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqTheta(1):freqTheta(2),tr:t0),4),3) / outputStruct.Trial(i).thetaBL;
        outputStruct.Trial(i).theta_t0_toff1_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqTheta(1):freqTheta(2),t0:toff1),4),3) / outputStruct.Trial(i).thetaBL;
        outputStruct.Trial(i).theta_gait_firstStep_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqTheta(1):freqTheta(2),t0:fc1),4),3) / outputStruct.Trial(i).thetaBL;
        
        
        %% alpha
        alpha  = [7 13];%Hz
        freqAlpha(1) = find(abs(inputStruct.TimeFreqData.freq - alpha(1)) == min(abs(inputStruct.TimeFreqData.freq - alpha(1))));
        freqAlpha(2) = find(abs(inputStruct.TimeFreqData.freq - alpha(2)) == min(abs(inputStruct.TimeFreqData.freq - alpha(2))));
        
        outputStruct.Trial(i).alphaBL = mean(mean(inputStruct.TimeFreqData.blPowspctrm(i,1,freqAlpha(1):freqAlpha(2),:),4),3);
        outputStruct.Trial(i).alpha_tr_t0_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqAlpha(1):freqAlpha(2),tr:t0),4),3) / outputStruct.Trial(i).alphaBL;
        outputStruct.Trial(i).alpha_t0_toff1_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqAlpha(1):freqAlpha(2),t0:toff1),4),3) / outputStruct.Trial(i).alphaBL;
        outputStruct.Trial(i).alpha_gait_firstStep_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqAlpha(1):freqAlpha(2),t0:fc1),4),3) / outputStruct.Trial(i).alphaBL;
        
        
        %% betaLow
        betaLow  =[13 20];%Hz
        freqBetaLow(1) = find(abs(inputStruct.TimeFreqData.freq - betaLow(1)) == min(abs(inputStruct.TimeFreqData.freq - betaLow(1))));
        freqBetaLow(2) = find(abs(inputStruct.TimeFreqData.freq - betaLow(2)) == min(abs(inputStruct.TimeFreqData.freq - betaLow(2))));
        
        outputStruct.Trial(i).betaLowBL = mean(mean(inputStruct.TimeFreqData.blPowspctrm(i,1,freqBetaLow(1):freqBetaLow(2),:),4),3);
        outputStruct.Trial(i).betaLow_tr_t0_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqBetaLow(1):freqBetaLow(2),tr:t0),4),3) / outputStruct.Trial(i).betaLowBL;
        outputStruct.Trial(i).betaLow_t0_toff1_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqBetaLow(1):freqBetaLow(2),t0:toff1),4),3) / outputStruct.Trial(i).betaLowBL;
        outputStruct.Trial(i).betaLow_gait_firstStep_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqBetaLow(1):freqBetaLow(2),t0:fc1),4),3) / outputStruct.Trial(i).betaLowBL;
        
        
        %% betaHigh
        betaHigh  =[20 35];%Hz
        freqBetaHigh(1) = find(abs(inputStruct.TimeFreqData.freq - betaHigh(1)) == min(abs(inputStruct.TimeFreqData.freq - betaHigh(1))));
        freqBetaHigh(2) = find(abs(inputStruct.TimeFreqData.freq - betaHigh(2)) == min(abs(inputStruct.TimeFreqData.freq - betaHigh(2))));
        
        outputStruct.Trial(i).betaHighBL = mean(mean(inputStruct.TimeFreqData.blPowspctrm(i,1,freqBetaHigh(1):freqBetaHigh(2),:),4),3);
        outputStruct.Trial(i).betaHigh_tr_t0_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqBetaHigh(1):freqBetaHigh(2),tr:t0),4),3) / outputStruct.Trial(i).betaHighBL;
        outputStruct.Trial(i).betaHigh_t0_toff1_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqBetaHigh(1):freqBetaHigh(2),t0:toff1),4),3) / outputStruct.Trial(i).betaHighBL;
        outputStruct.Trial(i).betaHigh_gait_firstStep_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqBetaHigh(1):freqBetaHigh(2),t0:fc1),4),3) / outputStruct.Trial(i).betaHighBL;
        
        
        %% gamma
        gamma  =[40 80];%Hz
        freqGamma(1) = find(abs(inputStruct.TimeFreqData.freq - gamma(1)) == min(abs(inputStruct.TimeFreqData.freq - gamma(1))));
        freqGamma(2) = find(abs(inputStruct.TimeFreqData.freq - gamma(2)) == min(abs(inputStruct.TimeFreqData.freq - gamma(2))));
        
        outputStruct.Trial(i).gammaBL = mean(mean(inputStruct.TimeFreqData.blPowspctrm(i,1,freqGamma(1):freqGamma(2),:),4),3);
        outputStruct.Trial(i).gamma_tr_t0_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqGamma(1):freqGamma(2),tr:t0),4),3) / outputStruct.Trial(i).gammaBL;
        outputStruct.Trial(i).gamma_t0_toff1_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqGamma(1):freqGamma(2),t0:toff1),4),3) / outputStruct.Trial(i).gammaBL;
        outputStruct.Trial(i).gamma_gait_firstStep_ratioFromBL = mean(mean(inputStruct.TimeFreqData.powspctrm(i,1,freqGamma(1):freqGamma(2),t0:fc1),4),3) / outputStruct.Trial(i).gammaBL;
    catch
        disp(['Not all events for trial ' inputStruct.TimeFreqData.TrialName(i)]);
    end
    
    
end

end