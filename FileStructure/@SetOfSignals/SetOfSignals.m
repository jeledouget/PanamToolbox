classdef SetOfSignals
    
    %SETOFTRIALS Class containing information about a set of trials
    % e.g. a set of trials can contain the LFP signals for one subject and
    % one condition
    
    properties
        Infos@containers.Map = containers.Map;
        Trials@struct vector;
        RemovedTrials@struct vector;
        History@cell matrix;
    end
    
    methods
        function self = SetOfSignals
            a.Infos = [];
        end
        
    end
    
end

