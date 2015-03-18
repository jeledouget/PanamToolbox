classdef Signal
    
    %SIGNAL Class for signal objects
    % A signal has a Data and Time component
    %
    %Data = data of the signal (m channels x n samples : double)
    %Fech = Sampling frequency (1 x 1 : double)
    %Tag = names of the m channels : (m x 1 : string);
    %Units = unit of the channels : (m x 1 string)
    %TrialName = name of the source file (1 x 1 : string);
    %TrialNum = number of the trial in a list of trials (1 x 1 : double);
    %Description = description of the signal (1 x 1 string);
    %History = history of operations applied on the object (n x 2 string cells)
    %Time = time vector (1 x n samples : double);
    
    %% properties
    properties
        Fech = [];
        Data = [];
        Tag = {''};
        Units = {''};
        Time = [];
        TrialName = '';
        TrialNum = [];
        Description = '';
        History = {};
    end
    
    %% methods
    
    methods
        
        % constructor
        function self = Signal(data, fech, varargin)
            % varargin format : (...,'PropertyName', 'PropertyValue',...)
            self.Fech = fech;
            self.Data = data;
            self.Time = (1:size(data,2))/fech;
            self.History{end+1,1} = datestr(clock);
            self.History{end,2} = 'Creation of the Signal structure';
            if nargin >= 3 && ~isempty(varargin{1})
                if mod(length(varargin{1}),2)==0
                    for i_argin = 1 : 2 : length(varargin{1})
                        switch lower(varargin{1}{i_argin})
                            case 'tag'
                                self.Tag = varargin{1}{i_argin + 1};
                            case 'units'
                                self.Units = varargin{1}{i_argin + 1};
                            case 'trialname'
                                self.TrialName = varargin{1}{i_argin + 1};
                            case 'trialnum'
                                self.TrialNum = varargin{1}{i_argin + 1};
                            case 'description'
                                self.Description = varargin{1}{i_argin + 1};
                            case 'time'
                                self.Time = varargin{1}{i_argin + 1};
                            otherwise
                                error(['Propriete ' varargin{1}{i_argin} 'inexistante dans la classe'])
                        end
                    end
                else
                    error('Nombre impair d''arguments supplementaires')
                end
            end
        end
        
       
        % other methods
        lpFilteredSignal = LowPassFilter(self, cutoff, order);
        hpFilteredSignal = HighPassFilter(self, cutoff, order);
        notchedSignal = NotchFilter(self, width, order);
        bpFilteredSignal = BandPassFilter(self, cutoffLow, cutoffHigh, order);
        zeroMeanSignal = MeanRemoval(self);
        TKEOSignal = TKEO(self);
        resampledSignal = Resampling(self, newFreq);
        timeWindowedSignal = TimeWindow(thisObj, minTime, maxTime);
        RmsSignal = RMS_Signal(self, timeWindow);

        
    end
end