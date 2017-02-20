%% Behavioral Experiment: TOTAL_RECALL
%
% Usage: total_recall
% At start, will prompt for the following required inputs:
%   Practice?
%   Enter Debug Mode.
%   Subject Number.
%
% Written by Kyle Kurkela, Febuary 2017
% See https://github.com/memobc/TOTAL_RECALL for more information

%% Initialize experiment-specific settings

% clear the workspace and add the ./functions directory to the MATLAB 
% search path
clear
addpath(genpath([pwd filesep 'functions']))

% Ask the user for input

% DBmode   = Debugging Mode (smaller screen)
% subject  = subject number

% Defaults
DBmode  = 'n';
subject = 'test';

practice = input('Practice? y/n: ', 's');
if strcmp(practice, 'n')
    DBmode   = input('Debug mode? y/n: ', 's');
    subject  = input('Enter subject ID: ', 's');
    cnbal    = input('Counter Balance?: ', 's');
end

% Hard coded yes/no variables:
% y = yes
% n = no
YN.auto = 'n';  % autoskip instruction screens

% Initalize Psychtoolbox
if strcmp(practice, 'n')
    init_psychtoolbox(DBmode);
else
    init_psychtoolbox(practice);
end

% Time Stamp
TimeStamp = [datestr(clock,'yyyy-mm-dd-HHMM') datestr(clock, 'ss')];

% if running debug mode, make the experiment go faster
if strcmp(practice, 'y')
    fast = 1;
else
    if strcmp(DBmode, 'y')
        fast = 1; % .5 = 2x as fast, .1 = 10x as fast, 1 = real time, ect.
    else
        fast = 1;
    end
end

%% Run Experiment

try
    %% Try Running Experiment
    
    % Generate Recall Lists
    path_to_stim   = [pwd filesep 'stim' filesep 'Long_et_al_2015_stimuli.csv'];
    if strcmp(practice, 'y')
        Experiment = generate_lists('practice', path_to_stim);
    else
        Experiment = generate_lists('experiment', subject,  path_to_stim, cnbal);
    end
    
    %-- Welcome to Study!

    instructions = 'Welcome to our experiment!';
    directions   = 'Press spacebar to continue';
    expStart     = instructions_screen(instructions, directions, YN.auto);

    %-- Experiment
    
    for session = 1:max(Experiment.sessionID)
        
        % sess filt
        sess_filt = Experiment.sessionID == session;
        
         %-- Welcome to Session
        instructions = ['Welcome to Session ' num2str(session) ' of ' num2str(max(Experiment.sessionID))];
        directions   = 'Press spacebar to continue';
        sessStart = instructions_screen(instructions, directions, YN.auto); 
    
        for list = Shuffle(unique(Experiment.listID(sess_filt))')
            
            % Grab current Study List
            StudyList = Experiment(Experiment.listID == list, :);

            % Run experiment!
            recall;

        end
    
    end
    
    %-- End of Study Screen

    instructions = 'You are finished with the experiment!';
    directions   = '';
    instructions_screen(instructions, directions, 'y');
        
    %% Finish up
    
    % Close all PTB screens (sca) and show the cursor again (ShowCursor)
    sca;
    ShowCursor;
    
    % If we are using a PC, show the task bar at the bottom
    if strcmp(computer, 'PCWIN')
        ShowHideWinTaskbarMex(1);
    end
    
    % Close all files that are currently open in MATLAB, set the priority
    % back to zero, and allow keystrokes to enter MATLAB's Command Window
    fclose('all');
    Priority(0);
    ListenChar(0);
        
catch
 %% If something goes wrong..
 
    % catch error in case something goes wrong in the 'try' part
    % Do same cleanup as at the end of a regular session

    % Close all PTB screens (sca) and show the cursor again (ShowCursor) 
    sca;
    ShowCursor;
    
    % If we are using a PC, show the task bar at the bottom    
    if strcmp(computer, 'PCWIN')
        ShowHideWinTaskbarMex(1);
    end
    
    % Close all files that are currently open in MATLAB, set the priority
    % back to zero, and allow keystrokes to enter MATLAB's Command Window
    fclose('all');
    Priority(0);
    ListenChar(0);
    
    % Output the error message that describes the error
    psychrethrow(psychlasterror);
    
end