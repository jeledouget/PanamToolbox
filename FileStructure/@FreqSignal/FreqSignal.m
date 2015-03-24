classdef FreqSignal < Signal
    
    %FREQSIGNAL Class for freq-sampled signal objects
    % A signal has a Data and Freq component
    %
    % 

    
    %% properties
    properties
        
    end
    
    %% methods
    
    methods
        
        % constructor
        function self = FreqSignal(data, varargin)
            self@Signal(data,varargin);
        end
        
        % get freq
        function freq = Freq(self, index)
            if nargin < 2 || isempty(index)
                freq = self.Dimensions('freq');
            else
                freqTmp = self.Dimensions('freq');
                freq = freqTmp(index);
            end
        end
        
        
    end
end