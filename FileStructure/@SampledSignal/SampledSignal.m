classdef SampledSignal < TimeSignal
    
    % SAMPLEDSIGNAL Class for time-sampled signal objects with regular time space
    % 1st Dimension of Data property is for time
    %
    % Properties:
    % Fs = sampling frequency (usually Hz)
    
    
    
    %% properties
    
    properties
        Fs; % sampling frequency
    end
    
    
    
    %% methods
    
    methods
        
        %% constructor
        
        function self = SampledSignal(varargin)
            subclassFlag = 0;
            indicesVarargin = []; % initiate vector for superclass constructor
            indFs = [];
            indTstart = [];
            indZerosample = [];
            if nargin > 1
                for i_argin = 1 : 2 : length(varargin)
                    switch lower(varargin{i_argin})
                        case 'fs'
                            indFs = i_argin + 1;
                        case 'tstart' % time of the first sample
                            indTstart = i_argin + 1;
                        case 'zerosample' % index of sample with time 0
                            indZerosample = i_argin + 1;
                        case 'subclassflag'
                            subclassFlag = varargin{i_argin + 1};
                        otherwise
                            indicesVarargin = [indicesVarargin i_argin i_argin+1];
                    end
                end
            end
            self@TimeSignal(varargin{indicesVarargin}, 'subclassflag', 1);
            if ~isempty(indFs), self.Fs = varargin{indFs};end 
            if ~isempty(indTstart), self.Temp.tstart = varargin{indTstart};end
            if ~isempty(indZerosample), self.Temp.zerosample = varargin{indZerosample};end
            if ~subclassFlag
                self.History{end+1,1} = datestr(clock);
                self.History{end,2} = 'Calling SampledSignal constructor';
                self = self.setDefaults;
                self.checkInstance;
                self = self.clearTemp;
            end
        end
        
        
        %% set, get and check methods
        
        % set methods
        function self = set.Fs(self, fs)
            if ~isscalar(fs) || ~isnumeric(fs)
                error('Fs property must be a numeric scalar');
            end
            self.Fs = fs;
        end
        
        % set default values
        function self = setDefaults(self)
            self = self.setDefaultChannelTags;
            self = self.setDefaultDimOrder;
            self = self.setDefaultFs;
            self = self.setDefaultTime;
        end
        
        % set default Fs property
        function self = setDefaultFs(self)
            if isempty(self.Fs)
                self.Fs = 1;
                warning('Fs property has been set at default value, ie. 1Hz');
            end
        end
        
        % set default Time property
        function self = setDefaultTime(self)
            if isempty(self.Time)
                nSamples = size(self.Data, 1);
                if isfield(self.Temp,'tstart')
                    self.Time = self.Temp.tstart + 1 / self.Fs * (0:nSamples-1);
                    if isfield(self.Temp,'zerosample')
                        warning('zerosample not taken into account, conflict with tstart');
                    end
                elseif isfield(self.Temp,'zerosample')
                    self.Time = 1 / self.Fs * ((1:nSamples) - self.Temp.zerosample);
                else % no tsart nor zerosample nor predefined time sample
                    self.Time = 1 / self.Fs * (0:nSamples-1);
                    warning('tsart assumed to be 0 (default value)');
                end
            end
        end
        
        % check instance properties
        function checkInstance(self)
            self.checkData;
            self.checkChannelTags;
            self.checkDimOrder;
            self.checkTime;
        end
        
        % check Time property
        function checkTime(self)
            self.checkTime@TimeSignal;
            % check sampling step ; allow 5% error per step, 1% error for average step
            steps = self.Time(2:end) - self.Time(1:end-1);
            if any(steps > 1.05/self.Fs) || any(steps < 0.95/self.Fs)
                error('inconsistency between sampling frequency and actual time samples : over the 5% margin error for successive time steps');
            end
            if (mean(steps) > 1.01/self.Fs) || (mean(steps) < 0.99/self.Fs)
                error('inconsistency between sampling frequency and actual time samples : over the 1% margin error for average time step');
            end
        end
        
        
        %% other methods
        
        
        %% external methods
        
        lpFilteredSignal = lowPassFilter(self, cutoff, order)
        hpFilteredSignal = highPassFilter(self, cutoff, order)
        notchedSignal = notchFilter(self, width, order)
        bpFilteredSignal = bandPassFilter(self, cutoffLow, cutoffHigh, order)
        TKEOSignal = TKEO(self)
        resampledSignal = resampling(self, newFreq)
        RmsSignal = RMS_Signal(self, timeWindow)
        
        
    end
end