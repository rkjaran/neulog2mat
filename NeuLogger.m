% Copyright 2014 Róbert Kjaran
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

classdef NeuLogger < handle 
% Matlab wrapper for the NeuLog HTTP API
    
    properties (SetAccess = private, GetAccess = public)
        % sensors is a struct array with properties 'type' and 'ID'
        % which define a NeuLog sensor
        Sensors
        Host
        Port
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
                
            obj.Host = host;
            obj.Port = port;
            obj.Sensors = [];
        end
        
        function version = GetServerVersion(obj)
        % Returns the server version number
        %
        % Usage: version = logger.GetServerVersion
        % 
                      
            s = obj.Send('GetServerVersion');
            
            version = parse_json(s);
            version = version{1}.GetServerVersion;
        
        end
        
        function status = GetServerStatus(obj)
        % Returns the status of the connected server
        %
        % Usage: status = logger.GetServerStatus;
        %
        % Returns ( 'Ready' | 'USB missing' | 'Recording' )
        %
                      
            s = obj.Send('GetServerStatus');
            status = parse_json(s);
            status = status{1}.GetServerStatus;

        end
        
        function senValues = GetSensorValue(obj, varargin)
        % Returns a row vector of point values from each sensor, ordered by the ordered the sensors were added.
        %
        % Usage: sensValues = logger.GestSensorValue; 
        %   Returns a row vector of point values from the sensors added with
        %   logger.AddSensor; 
        %
        % Usage: sensValues = logger.GetSensorValue(sen1 [, sen2, ...]);
        %   where seni is a struct with properties 'type' and 'ID'
        %   (See AddSensor)
        %
            if nargin == 1
                % No parameter passed -> use the sensors added with
                % obj.AddSensor()
                if isempty(obj.Sensors)
                   error('NeuLogger:noSensors', ['No sensors have been added, ' ...
                                       'see NeuLogger.AddSensor(...)']);
                end
                
                args = '';
                for sen = obj.Sensors
                    args = [args '[' sen.type '],[' num2str(sen.ID) '],' ]; %#ok
                end
                command = 'GetSensorValue:';
                s = obj.Send([command args(1:end-1)]);
                senValues = parse_json(s);
                if ~iscell(senValues{1}.GetSensorValue)
                    error('NeuLogger:failedResponse', ['Failed to get point ' ...
                                        'value for sensors.']);
                end
                senValues = cell2mat(senValues{1}.GetSensorValue);
                
            else
                % we assume every argument passed is a struct:'type','ID'
                error('NeuLogger:notImplemented', 'Not implemented yet');
            end
        end
        
        function bool = ResetSensor(obj, sen) %#ok
        % Calibrates the sensor 'sen' and returns true if successful
        % Not used for GSR
        % IMPLEMENT LATER
            error('NeuLogger:notImplemented', 'Not implemented yet.');
        end
        
        function bool = SetPositiveDirection(obj, sen) %#ok
        % Sets the direction of a 'Force' sensor, returns true if successful
        % sen is a struct with properties 'type', 'ID' and 'dir'
        % Not used for GSR
        % IMPLEMENT LATER
            error('NeuLogger:notImplemented', 'Not implemented yet.');
        end
        
        function bool = StartExperiment(obj, varargin)
        % Starts an experiment by collecting samples from selected sensors,
        % returns true if successfully started
        %
        % Usage: logger.StartExperiment(samplerate, numsamples)
        %   Start collecting numsamples at samplerate (see rate index in manual)
        %   Uses sensors added with logger.Addsensor(type,ID)
        %
        % Usage: logger.StartExperiment(sensors, samplerate, samples)
        %   Start collecting numsamples at samplerate (see rate index in manual)
        %   sensors is a struct array with properties 'type' and 'ID'
        %   Overwrites the sensors previously added with logger.AddSensor 
        %
            if nargin == 3
                samplerate = varargin{1};
                numsamples = varargin{2};
            elseif nargin == 4
                obj.Sensors = varargin{1};
                samplerate = varargin{2};
                numsamples = varargin{3};
            else
                error('NeuLogger:argChk', 'Wrong number of input arguments.')
            end
            
            args = '';
            for sen = obj.Sensors
                args = [ args '[' sen.type '],[' num2str(sen.ID) '],' ]; %#ok
            end
            
            command = 'StartExperiment:';
            args = [ args '[' num2str(samplerate) '],[' num2str(numsamples) ']' ];
            s = obj.Send([command args]);
            status = parse_json(s);

            bool = status{1}.StartExperiment(1) == 'T';
        end
        
        function bool = StopExperiment(obj)
        % Stops a running experiment, returning true if successfully stopped
            
            s = obj.Send('StopExperiment');
            status = parse_json(s);

            bool = status{1}.StopExperiment(1) == 'T';
        end
        
        function sampleStruct = GetSamples(obj, varargin)
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
            if nargin == 1
                % use the sensors added with obj.AddSensor(...)
                % begin by building the query
                args = '';
                for sen = obj.Sensors
                    args = [ args '[' sen.type '],[' num2str(sen.ID) '],' ]; %#ok
                end
                args = args(1:end-1); % remove trailing ','
                command = 'GetExperimentSamples:';
                s = obj.Send([ command args ]);
                res = parse_json(s);
                
                sampleStruct = [];
                for item = res
                    s.sen.type = res{1}{1};
                    s.sen.ID   = res{1}{2};
                    s.samples  = cell2mat(res{1}(3:end));
                    sampleStruct = [ sampleStruct s ]; %#ok
                end
                
            elseif nargin == 2
                % assume sen is a struct:'type','ID'
                error('NeuLogger:notImplemented', 'Not implemented yet.');                
            end
            
        end
        
        function bool = SetSensorRange(obj, sen, range)
        % Sets the range of the sensor 'sen' (doesn't have to have been added
        % to the current logger)
        %
        % Usage: SetSensorRange(sen, range);
        %   Sets the range of sensor 'sen' (struct with props. 'type' and
        %   'ID'). See manual for sensor for definition of 'range'.
        %
            
            command = 'SetSensorRange:';
            args    = ...
                [ '[' sen.type '],[' num2str(sen.ID) '],[' num2str(range) ']'];
            s = obj.Send([ command args ]);
            bool = parse_json(s);
            bool = bool{1}.SetSensorRange(1) == 'T';

        end
        
        function bool = SetRFID(obj)
        % TODO FIXME: the API doesn't say what this actually does?
            error('NeuLogger:notImplemented', 'Not implemented yet.');
        end
        
        function bool = SetSensorsID(obj, NewID)
        % Sets the ID of all sensors connected to the actual device to
        % 'NewID', returns true if successful
            error('NeuLogger:notImplemented', 'Not implemented yet.');
        end
    end

    %% Added functionality
    methods
        function AddSensor(obj, type, ID)
        % Notify the NeuLogger object about a sensor
        %
        % Usage: logger.AddSensor(type[, ID])
        % where type = ('GSR' | 'Temperature' | whatever the API recognizes )
        % and ID is an integer denoting the sensor ID (defaults to ID=1)
        %
            if ~ischar(type)
                error('NeuLogger:badArgs', ['First argument is a string ' ...
                                    'representing the type of sensor!']);
            end
            if nargin == 2
                ID = 1;
            end
            obj.Sensors = [obj.Sensors struct('type', type, 'ID', ID)];
        end
    end
    
    methods (Access = private)
        function [response, status] = Send(obj, APICommand)
        % Send the raw string APICommand to NeuLog API
        % Returns the string (JSON) returned
            [response, status] = ...
                urlread(['http://' obj.Host ':' num2str(obj.Port) '/NeuLogAPI?' APICommand]);
            
            if ~status
                error('NeuLogger:Send', 'Invalid or no reply from server');
            end
            
            if lower(response(1)) == 'f'
                error('NeuLogger:Send', 'Invalid command');
            end

        end
    end
end

