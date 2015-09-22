%% Tutorial 1
% 
% It is advised to use the matlab 'Cell Mode' and to run this tutorial 
% cell-by-cell.
%
% This first tutorial explains the structure of data access allowed by
% Panam_Toolbox

%#ok<*NOPTS>

%% Architecture of data types
% 
% Panam_Toolbox makes use of the object-oriented abilities of Matlab.
% Several generic classes are implemented, each one with specific Properties
% (equivalent to fields for Matlab structures) and methods (equivalent to
% functions).
% Properties can be accessed in Matlab just as for usual structure fields.
% Note that in this toolbox, properties start with an uppercase while
% methods start with a lowercase.
%
% The 'central' class is called Signal.
%
% Then, subclasses are created to account for specificities of Signal
% objects : do they have a time axis, a freq axis, etc. ?
% Subclasses inherit methods and properties from their parent class.
%

% Signal subclasses architecture :
% 
%                       Signal
%                       -     -
%                      -       - 
%                     -         - 
%           TimeSignal           FreqSignal
%           -          -          -
%          -             -       -    
%         -                -    -
%  SampledTimeSignal      TimeFreqSignal
%
% Also, time events are formalised in a SignalEvents class and and equivalent
% frequency marker class called FreqMarkers has been implemented.

         
        
%% Create your first Signal object


% Signal class contains the following properties :
% - Data : a numeric matrix
% - ChannelTags : cell of channel names
% - DimOrder : cell of dimension names in Data -> 'time', 'freq', 'chan' or whatever else. 'chan' always goes last
% - Infos : structure in which fields are filled by the user to save information relative to the Signal object
% - History : cell of strings that include an history of the operations applied on the Signal object
% - Temp : Hidden propoerty, can be used to ave some extra data that is not visible 


% 1) Create a default Signal object (all properties set to defaults)
test = Signal();test
% You can see that that properties are printed at the command window


% 2) Input Data
data = rand(10,5); % random data matrix
test = Signal('data', data);test
% You can see that default values are affected to properties that have not
% been explicitely initialized by the user. For instance, channels are
% named 'chan1', 'chan2' etc. according to the size of the last dimension
% of the Data property.


% 3) Input several properties
data = rand(10,5,3);
infos.patientNames = {'Dupont', 'Durand', 'Michaud'};
infos.yearOfMeasurement = '2015';
infos.placeOfMeasurement = 'ICM';
test = Signal('data', data, 'channeltags', {'C01D', 'C12D', 'C01G'} , 'dimorder', {'days', 'patient', 'chan'}, 'infos', infos);
test.ChannelTags
test.DimOrder
test.Infos
% Please note that properties are input as key-value pairs. The order of
% the properties does not matter, nor the case ('ChannelTags' and
% 'channeltags' are equivalent) :
test2 = Signal('channelTAGS', {'C01D', 'C12D', 'C01G'}, 'DimOrder', {'days', 'patient', 'chan'}, 'infos', infos, 'DATA', data);
isequal(test, test2)


% 4) Incorrect inputs raise errors :
test = Signal('data', data,'dimorder', {'days', 'patient'}); % only 2 dimensions instead of 3
test = Signal('data', data,'channeltags', {'C01D','C12D'}); % channeltags does not correspond to the size of the 'chan' dimension of Data
% The last dimension does not have to be 'chan' but this is strongly
% advised as most methods consider that the last dimension of the Data
% property to correspond to the Channels dimension.


% Feel free to try a few initialisations of Signal instances !



%% Discover TimeSignal, SampledTimeSignal, FreqSignal, TimeFreqSignal objects


% 1) TimeSignal objects

% TimeSignal class is a child of the Signal class and therefore inherits all its
% properties and methods. In addition, TimeSignal objects possess a Time vector
% (an ordered vector of doubles, or a cell of strings) and an Events
% vector, which is an array of SignalEvents elements and that is used to
% store events that occur during the process of the Signal. Details on the
% SignalEvents class are given later.

% Initialize :
test = TimeSignal('data', rand(9,2));test
% You can see that by default the time vector starts from 0 and increments
% by 1, and the dimensions are 'time' and 'chan'.

% You can input time vector as you wish as long as it is an increasing
% vector :
test = TimeSignal('time', [0 4 6 12 15], 'data', rand(5,2));test
test = TimeSignal('time', [15 4 6 12 0], 'data', rand(5,2));test

% If a third dimension is added, you can see that DimOrder becomes {'time'
% 'dim2'  'chan'} :
test = TimeSignal('time', [0 1 3 4 6 7 8 12 15], 'data', rand(9, 5,2));test
% TimeSignal have their first dimension as 'time' and their last dimension
% as 'channels' and it is strongly advised to leave it this way, since a
% lot of methods will assume that.

% Time vector can be a cell of strings :
test = TimeSignal('time', {'Baseline', 'Day1', 'Day2'}, 'data', rand(3,2));test

% Incorrect output raise errors
test = TimeSignal('time', {'Baseline', 'Day1'}, 'data', rand(3,2));



% 2) SampledTimeSignal objects

% SampledTimeSignal class is a child of TimeSignal class and therefore
% inherits all its properties and methods.
% In addition, SampledTimeSignal have a sampling rate Property Fs.
test = SampledTimeSignal('data', rand(11,2));test
% You can see that by default Fs is set to 1

% If you want to set a specific sampling rate Fs:
test = SampledTimeSignal('fs', 10, 'data', rand(11,2));test
% or with 'dt' :
test = SampledTimeSignal('dt', 0.1, 'data', rand(11,2));test
% You can see Time vector starts at 0 by default.
% You can change that with tstart :
test = SampledTimeSignal('fs', 10, 'tstart',2,'data', rand(11,2));test
% or 'zerosample' to set the sample at which time is 0 :
test = SampledTimeSignal('fs', 10, 'zerosample',5,'data', rand(11,2));test

% You can also input the time and Fs is calculated
test = SampledTimeSignal('time', 0:3:30, 'zerosample',5,'data', rand(11,2));test
% Incorrect output raise errors : here the time vector is not equally
% spaced
test = SampledTimeSignal('time', [0 1 2 3 6 9 12], 'zerosample',5,'data', rand(7,2));test


% 3) FreqSignal objects

% FreqSignal objects are very similar to TimeSignal objects except that
% Time property is replaced by Freq and Events by FreqMarkers
test = FreqSignal('freq', [0 4 6 12 15], 'data', rand(5,2));test
% As you can see here the first dimension is 'freq' and the last remains
% 'chan'


%% Add Events or FreqMarkers

% 1) SignalEvents :
% 
% SignalEvents class includes 4 properties :
% - EventName : a string that is the identifier of the name of the event
% - Time : a vector of times
% - Duration : a vector of event durations
% - Infos : a structure that encapsulates all information that the user
% wishes to associate with the event

% The properties must be input in this order, no key-value pari here :
test = SignalEvents('event1', 3,0, struct('type', 'stimulus'));test
test.Infos
% it is possible to have several events times 
test = SignalEvents('event1', [2 3 7 9],[0 0 1 1], struct('type', 'stimulus'));test

% Duration must be same length as Time property though
test = SignalEvents('event1', [2 3 7 9],[0 0], struct('type', 'stimulus'));test
% if Duration is to be set to 0, it can be input as [] or unfilled
test = SignalEvents('event1', [2 3 7 9],[], struct('type', 'stimulus'));test
test = SignalEvents('event1', [2 3 7 9]);test

% 2) FreqMarkers
% 
% FreqMarkers class is the equivalent to SignalEvents, but considering
% frequency instead of time
% - Property Freq replaces Time
% - Property Window replaces Duration
% - Property MarkerName replaces EventName
test = FreqMarkers('alpha', 7,6);test % alpha : 7 to 13Hz


%% Encapsulate in a SetOfSignals

% The class SetOfSignals is useful to encapsulate Signal objects
% It contains the following properties:
% - Signal: matrix of 'Signal' or 'Signal' subclass instances
% - Infos :  common information to all the signals included in the Signals property
% - DimOrder : cell of strings with dimensions of the Signals property
% - History : history of operations on the SetOfSignals instance

% A SetOfSignals object can therefore contain a Signals array and save a
% common History of the operations that have been performed on the elements
% of the Signals array.
% It can also store information (Infos property) common to all the elements
% of the Signals array, as well as the meaning of the dimension of the
% Signals array (for instance 'conditions', and 'trials')


