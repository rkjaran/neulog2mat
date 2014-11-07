classdef NeuLogger 
    
    properties (SetAccess = private, GetAccess = private)
        % sensors is a struct array with properties 'type' and 'ID'
        % which define a NeuLog sensor
        sensors 
    end
    
    %% API wrapper
    methods 
        function obj = NeuLogger(host, port)
        % Constructor for a connection to NeuLog sensor array (via
        % the HTTP API)
        %   
        % logger = NeuLogger;
        %     logger is a NeuLogger object connected to
        %     localhost:22002
        %
        % logger = NeuLogger(host, portnum)
        %    The connection is made via
        %    'http://host:port/NeuLogAPI?<request>
        %
            if nargin < 2
                host = 'localhost';
                port = 22002;
            end
            
            % TODO: implement
            
        end
        
        function version = GetServerVersion(obj)
        % Returns the server version number
        %
        % Usage: version = logger.GetServerVersion
        % 
                      
            ...
            % TODO: IMPLEMENT

        end
        
        function status = GetServerStatus(obj)
        % Returns the status of the connected server
        %
        % Usage: status = logger.GetServerStatus;
        %
        % Returns ( 'Ready' | 'USB missing' | 'Recording' )
        %
                      
            ...
            % TODO: IMPLEMENT

        end
        
        function senValues = GetSensorValue(obj, varargin)
        % Returns a point value from each sensor listed
        % 
        % Usage: sensValues = logger.GetSensorValue(sen1 [, sen2, ...]);
        %   where seni is a struct with properties 'type' and 'ID' (See AddSensor)
          
            ...
            % TODO: IMPLEMENT
        end
        
        function bool = ResetSensor(obj, sen)
        % Calibrates the sensor 'sen' and returns true if successful
        % Not used for GSR
        % IMPLEMENT LATER
            ...
        end
        
        function bool = SetPositiveDirection(obj, sen)
        % Sets the direction of a 'Force' sensor, returns true if successful
        % sen is a struct with properties 'type', 'ID' and 'dir'
        % Not used for GSR
        % IMPLEMENT LATER
            ...
        end
        
        function bool = StartExperiment(obj, varargin)
        % Starts an experiment by collecting samples from selected sensors,
        % returns true if successfully started
            
        % Usage: logger.StartExperiment(samplerate, numsamples)
        %   Start collecting numsamples at samplerate (in Hertz)
        %   Uses sensors added with logger.Addsensor(type,ID)
        %
        % Usage: logger.StartExperiment(sensors, samplerate, samples)
        %   Start collecting numsamples at samplerate (in Hertz)
        %   sensors is a struct array with properties 'type' and 'ID'
        %
            if nargin == 2
                samplerate = varargin{1};
                numsamples = varargin{2};
            elseif nargin == 3
                sensors = varargin{1};
                samplerate = varargin{2};
                numsamples = varargin{3};
                obj.sensor = sensors;
            else
                error('NeuLogger:argChk', 'Wrong number of input arguments')
            end
            
            ...
            % TODO: IMPLEMENT
            
            
        end
        
        function bool = StopExperiment(obj)
        % Stops a running experiment, returning true if successfully stopped
            
            ...
            % TODO: IMPLEMENT
        end
        
        function sampleStruct = GetSamples(obj, sen)
        % Returns samples from a running or finished experiment
        %
        % Usage: sampleStruct = logger.GetSamples;
        %   Returns experiment samples from all sensors added by
        %   logger.AddSensor or when logger.StartExperiment was called
        %
        %   Returns a struct array with properties 'sen', 'samples'
        %   sen is a struct with properties 'type', 'ID' and
        %   'samples' is a row vector of samples from samples read from
        %   sensor 'sen'. 
        %
        % Usage: samples = logger.GetSamples(sen)
        %   Returns experiment samples from sensor 'sen', where sen is a
        %   struct with properties 'type' and 'ID'
        %
            if nargin == 0 
                useSetSensors = true;
            else
                useSetSensor = false;
            end
            
            ...
            
            % TODO: IMPLEMENT
        end
        
        
        function bool = SetSensorRange(obj, sen, range)
        % Sets the range of the sensor 'sen' (doesn't have to have been added
        % to the current logger)
        %
        % Usage: SetSensorRange(sen, range);
        %   Sets the range of sensor 'sen' (struct with props. 'type' and
        %   'ID'). See manual for sensor for definition of 'range'.
        %
          
            ...
            
            % TODO: IMPLEMENT
        end
        
        function bool = SetRFID(obj)
        % TODO FIXME: the API doesn't say what this actually does?
        end
        
        function bool = SetSensorsID(obj, NewID)
        % Sets the ID of all sensors connected to the actual device to
        % 'NewID', returns true if successful
        end
        
        
        
        %% Added functionality
        function AddSensor(type, ID)
        % Notify the NeuLogger object about a sensor
        %
        % Usage: logger.AddSensor(type[, ID])
        % where type = ('GSR' | 'Temperature' | whatever the API recognizes )
        % and ID is an integer denoting the sensor ID (defaults to ID=1)
        %
            if nargin < 2
                ID = 1;
            end
            
            % TODO: IMPLEMENT
        end
    end
    methods (Access = private)
        
    end
end
