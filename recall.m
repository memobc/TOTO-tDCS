%% TOTAL RECALL Study: Experiment 1
% Called by total_recall.m
% Written by Kyle Kurkela, kyleakurkela@gmail.com Feburary 2017
% See https://github.com/memobc/TOTAL_RECALL for more information

%%
%==========================================================================
%				Settings
%==========================================================================

%-- Instructions
    
    % Instructions
    instructions = 'Please answer each question';
    
%-- Timing (all in seconds)
    
    preFix     = 1.5;

    sentTime   = 3;
    
    fixTime    = 1; % Long et al use a jittered ITI between 800 and 1200 ms
    
    postFix    = 1.3; % Long et al use a jittered delay between 1200 and 1400 ms
    
    recallTime = 75;
    
%-- Initialize Response Recorder Variables

    OnsetTime    = zeros(1, height(StudyList));
    resp         = cell(1, height(StudyList));
    resp_time    = zeros(1, height(StudyList));

%-- Create the Keyboard Queue (see KbQueue documentation), restricting
%   responses to the ENC_keylist keys (see init_psychtoolbox)
    rep_device = -1;
    keylist    = zeros(1, 256);
    keylist([KbName('1!') KbName('2@')]) = 1;    
    KbQueueCreate(rep_device, keylist)
    
%-- Establish global variables

    global W X Y

%%
%==========================================================================
%				Instructions
%==========================================================================
% Display instructions and wait for a participant's response before 
% continuing. Please see instructions_screen documentation for more 
% details. Written in a for loop to display multiple instructions screens,
% if desired.
    
instructions_screen(instructions, [], YN.auto);

%%
%==========================================================================
%				Pre Run Fixation
%==========================================================================
% Draw a fixation cross to the exact center of the screen. Update the 
% display and record the moment the fixation cross was displayed in the 
% variable "expstart". "expstart" will mark the beginning of the this run.
% Display this fixation cross for 2 seconds.

Screen('FillRect', W, [], [X/2-6 Y/2-4 X/2+6 Y/2+4]);
Screen('FillRect', W, [], [X/2-4 Y/2-6 X/2+4 Y/2+6]);
expstart = Screen('Flip', W);
WaitSecs(preFix * fast);

%%
%==========================================================================
%				Study
%==========================================================================
% Study Routine

% For each trial in Study...
for curTrial = randperm(height(StudyList))
        
    %-- Stimuli Screen

        % Draw the Memoranda
        DrawFormattedText(W, Experiment1.Word{curTrial}, 'center', 'center');
        
        % Draw Study Question (e.g., 'Will this item fit into a shoebox?' 'Does
        % this word refer to something living or not living?')
        DrawFormattedText(W, Experiment1.Question{curTrial}, 'center', 'center');
        
        % Draw Reponse Options (e.g., '1 = Def New      |     2 = Prob
        % New')
        DrawFormattedText(W, Experiment1.ResponseOptions{curTrial}, 'center', 'center');
        
        % Flush and start the Psychtoolbox Keyboard Queue. See KbQueue*
        % documentation
        KbQueueFlush(rep_device);
        KbQueueStart(rep_device);
        
        % Flip Screen (see Screen Flip documentation) and Record the Onset
        % Time
        OnsetTime(curTrial) = Screen(W, 'Flip');
        
        % Wait "picTime"
        WaitSecs(sentTime * fast);
                
        % Record Responses
        [resp{curTrial}, resp_time(curTrial)] = record_responses();
        
    %-- Post Trial ITI
        
        % Draw fixation cross, flip the screen, and wait "fixTime"
        DrawFormattedText(W, '+', 'center', 'center');
        Screen(W, 'Flip');
        WaitSecs(fixTime * fast);
        
end

%% 
%==========================================================================
%                       Post Study Delay
%==========================================================================
% Draw a fixation cross to the exact center of the screen. Update the 
% display and wait 2 seconds before advancing

Screen('FillRect', W, [], [X/2-6 Y/2-4 X/2+6 Y/2+4]);
Screen('FillRect', W, [], [X/2-4 Y/2-6 X/2+4 Y/2+6]);
Screen(W, 'Flip');
WaitSecs(postFix * fast);

%%
%==========================================================================
%				Recall
%==========================================================================
% Recall!

% Draw the Prompt
DrawFormattedText(W, '*****', 'center', 'center');

% Directions
DrawFormattedText(W, 'Recall! You have 75 Seconds\n\n Remember type all words in lowercase with spaces in between each word\n\n', 'center', 'center');

% Timing
time = GetSecs + recallTime;

% Flip Screen (see Screen Flip documentation) and Record the Onset Time
RecallOnset = Screen(W, 'Flip');

% Collect response
responseString = GetEchoString(W, 'Answers: ', X/3, 9*(Y/10), 0, 255, 1, -1, time);
        