classdef Signal_EMG < Signal
    
    %SIGNAL Summary of this class goes here
    %
    %Data = data of the signal (m channels x n samples : double)
    %Fech = Sampling frequency (1 x 1 : double)
    %Tag = names of the m channels : (m x 1 : string);
    %trial_name = name of the source file (1 x 1 : string);
    %trial_num = number of the trial in a list of trials (1 x 1 : double);
    %Description = description of the signal (1 x 1 string);
    %Time = time vector (1 x n samples : double);
    
   
    methods
        
        % constructor
        function sEMG = Signal_EMG(data, fech, varargin)
            sEMG@Signal(data, fech, varargin)
        end
        
        % other methods
        newSignal = TKEOprocess(thisSignal);
            
    end
end
