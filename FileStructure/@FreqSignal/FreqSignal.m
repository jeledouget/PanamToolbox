classdef FreqSignal < Signal
    
    %FREQSIGNAL Class for freq-sampled signal objects
    % A signal has a Data and Freq component
    %
    % Freq = numeric vector for frequency samples

    
    %% properties
    properties
        Freq; % numeric vector for frequency samples
    end
    
    %% methods
    
    methods
        
        % constructor
        function self = FreqSignal(data, varargin)
            superargs = varargin;
            indFreq = find(strcmpi(superargs,'freq'));
            if ~isempty(indFreq)
                freq = varargin{indFreq+1};
                if length(superargs) > 2
                    superargs = superargs{[1:indFreq-1 indFreq+2:end]};
                else
                    superargs = {};
                end
            else
                freq = 1:size(data,1);
            end
            self@Signal('data',data, superargs{:});
            self.Freq = freq;
        end
        
        % set freq
        function self = set.Freq(self, freq)
            if ~isnumeric(freq) || ~isvector(freq)
                error('''Freq'' property must be set as a numeric vector');
            end
            self.Freq = freq;
        end
        
    end
end