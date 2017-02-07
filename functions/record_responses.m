function [response, response_time] = record_responses(varargin)

%% Parse Input Arguments
    
    % Defaults
    settings = ...
        {-1;
        '';
        NaN};
     
     % User Specified Settings
     filter = ~cellfun('isempty', varargin);
     settings(filter) = varargin(filter);
     [resp_device, NR_resp, NR_time] = settings{:};
    
%% Record Responses

    % Stop recording of the KbQueue. See KbQueue* documentation
    KbQueueStop(resp_device);

    % Check the KbQueue
    [pressed, ~, ~, lastPress] = KbQueueCheck(resp_device);

    % If a key was pressed...
    if pressed

        % Record the name and onset time of the LAST key pressed
        response      = KbName(find(max(lastPress) == lastPress)); %#ok<*MXFND>
        response_time = max(lastPress(find(lastPress))); %#ok<*FNDSB>
        
        % There is a special case where the last key pressed was two 
        % (or more) keys simultaneously pressed. If this was the case, 
        % join them together into a character array
        if iscell(response)
            response  = strjoin(response);
        end
        
    else

        % No Response Trial
        response      = NR_resp;
        response_time = NR_time;

    end  

end