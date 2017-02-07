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

practice = input('Practice? y/n: ', 's');
if strcmp(practice, 'n')
    DBmode   = input('Debug mode? y/n: ', 's');    
    subject  = input('Enter subject ID: ', 's');
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
    
    % Generate the Study and Speeded Recognition Lists
    if strcmp(practice, 'y')
        [Study, Recognition] = generate_lists('practice');
        Test                 = generate_lists('test', Study);
    else
        path_to_stim   = [pwd filesep 'stim' filesep ''];
        Experiment1    = generate_lists('experiment1', path_to_stim);
        Experiment2    = generate_lists('experiment2', path_to_stim);
        Experiment3    = generate_lists('experiment3', path_to_stim);
    end
    
    %-- Welcome to Study!

    instructions = 'Welcome to our experiment!';
    directions   = 'Press spacebar to continue';
    instructions_screen(instructions, directions, 'n');    
    
    session = 0;
    list    = 0;
    
    %-- Experiment 1
    
    while session < 7 && strcmp(exp, 'exp1')
        
        session = session + 1;
        
         %-- Welcome to Session
        instructions = ['Welcome to Session ' num2str(session) ' of 7'];
        directions   = 'Press spacebar to continue';
        instructions_screen(instructions, directions, 'n'); 
    
        for l = 1:16
            
            % Advance list counter
            list = list + 1;

            % Grab current Study List
            StudyList = Experiment1(Experiment1.ListID == list, :);

            % Run experiment!
            experiment1;

        end
    
    end
    
    %-- Experiment 2
    
    while session < 7 && strcmp(exp, 'exp2')
        
        session = session + 1;

         %-- Welcome to Session
        instructions = ['Welcome to Session ' num2str(session) ' of 7'];
        directions   = 'Press spacebar to continue';
        instructions_screen(instructions, directions, 'n');
        
        while list < 12

            % Advance list counter        
            list = list + 1;

            % Grab current Study List
            StudyList = Experiment2(Experiment2.ListID == list, :);

            % Run experiment!
            experiment2;

        end
    
    end
    
    %-- Experiment 3
    
    while session < 7 && strcmp(exp, 'exp2')
        
        session = session + 1;

         %-- Welcome to Session
        instructions = ['Welcome to Session ' num2str(session) ' of 7'];
        directions   = 'Press spacebar to continue';
        instructions_screen(instructions, directions, 'n');
        
        for l = 1:12
        
            % Advance list counter
            list = list + 1;

            % Grab current Study List
            StudyList = Experiment3(Experiment3.ListID == list, :);

            % Run experiment!
            experiment3;
            
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