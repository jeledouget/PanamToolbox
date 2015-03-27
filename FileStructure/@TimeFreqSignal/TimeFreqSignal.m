classdef TimeFreqSignal < TimeSignal
    
    %TIMEFREQSIGNAL Class for time-frequency representations
    
    
    %% properties
    properties
        Freq; % numeric vector for frequency samples, or cell array (eg. {'alpha','beta'})
    end
    
    %% methods
    
    methods
        
        % constructor
        function self = TimeFreqSignal(data, varargin)
            indFreq = find(strcmpi(varargin,'freq'));
            if ~isempty(indFreq)
                freq = varargin{indFreq+1};
                if length(varargin) > 2
                    varargin = varargin{[1:indFreq-1 indFreq+2:end]};
                else
                    varargin = {};
                end
            else
                freq = 1:size(data,1);
            end
            self@TimeSignal(data,varargin{:});
            self.Freq = freq;
        end
        
        
    end
end