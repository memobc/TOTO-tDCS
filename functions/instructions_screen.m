function [varargout] = instructions_screen(varargin)

%% Parse Input Arguments
    
    global W Y

    % Defaults
    settings = ...
        {'Please answer the questions as quickly and accurately as you can';
         'Press spacebar to continue';
         'n';
         [KbName('space') KbName('escape')];
         -1;
         .200;
         2};
     
     % User Specified Settings
     filter = ~cellfun('isempty', varargin);
     settings(filter) = varargin(filter);
     [instructions, directions, autoskip, keys, resp_device, buffer, autoskipWait] = settings{:};
    
%% Instructions Screen

    DrawFormattedText(W, instructions, 'center', 'center');
    DrawFormattedText(W, directions, 'center', 4*(Y/5));
    Screen('Flip', W);
    WaitSecs(buffer);
    
    if strcmp(autoskip, 'n')
        
        oldkeys = RestrictKeysForKbCheck(keys);
        [~, keycode, ~] = KbStrokeWait(resp_device);
        
        if keycode(KbName('escape')) == 1
            varargout{1} = false;
            return
        else
            varargout{1} = true;
        end
        
        RestrictKeysForKbCheck(oldkeys);
        
    elseif strcmp(autoskip, 'y')
        
        WaitSecs(autoskipWait);
        
    end

end