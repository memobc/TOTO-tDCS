%% TOTAL RECALL Study: Experiment
% Called by total_recall.m
% Written by Kyle Kurkela, kyleakurkela@gmail.com Feburary 2017
% See https://github.com/memobc/TOTAL_RECALL for more information

%%
%==========================================================================
%				Settings
%==========================================================================

%-- Instructions
    
% Instructions
instructions = 'Please answer each question as quickly and accurately as you can';
    
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

global W X Y pahandle

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
liststart = Screen('Flip', W);
WaitSecs(preFix * fast);

%%
%==========================================================================
%				Study
%==========================================================================
% Study Routine

% For each trial in Study...
for curTrial = 1:height(StudyList)
        
    %-- Stimuli Screen

        % Draw the Memoranda
        [~, ny, ~] = DrawFormattedText(W, StudyList.Word{curTrial}, 'center', 'center');
        
        % Draw Study Question (e.g., 'Will this item fit into a shoebox?' 'Does
        % this word refer to something living or not living?')
        [~, ny, ~] = DrawFormattedText(W, 'Does this word refer to something living or not living?', 'center', ny + 200);
        
        % Draw Reponse Options (e.g., '1 = Def New      |     2 = Prob
        % New')
        DrawFormattedText(W, '1 = Living      |     2 = Non-Living', 'center', ny + 100);
        
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

% Release the KbQueue. See KbQueue* documentation
KbQueueRelease(rep_device);

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

% Timing
recallstart = GetSecs;
time        = recallstart + recallTime;

%-- Audio Recording

% Preallocate an internal audio recording buffer with a capacity of 75
% seconds.
PsychPortAudio('GetAudioData', pahandle, 75);

% Start audio capture.
PsychPortAudio('Start', pahandle);

while (time - GetSecs) >= 0
    
    % Directions
    [~, ny, ~] = DrawFormattedText(W, sprintf('Recall!\n\n You have %.0f Seconds Left', (time - GetSecs)), 'center', 'center');
        
    % Flip Screen (see Screen Flip documentation)
    Screen(W, 'Flip');

end

% get the audio OUT of the buffer and into a matrix
audiodata = PsychPortAudio('GetAudioData', pahandle);

% Stop audio capture.
PsychPortAudio('Stop', pahandle);

%%
%==========================================================================
%				Write Data
%==========================================================================
% Write out the results of this retrieval run. Add 5 relevant variables to
% the retrieval list:
%
%   Onset:     the moment in time, relative to the start of the list, that
%              this trial began
%
%   resp:      the key that was hit during this trial
%
%   resp_time: the moment in time, relative to the start of the list, 
%              that a response was made
%
%   rt:        the participants reaction time, calculated as Onset -
%              resp_time

if strcmp(practice, 'n')

    % Add data to `StudyList`
    StudyList.ExpOnset     = OnsetTime' - expStart;
    StudyList.SessOnset    = OnsetTime' - sessStart;
    StudyList.ListOnset    = OnsetTime' - liststart;
    StudyList.resp         = resp';
    StudyList.resp_time    = resp_time' - liststart;
    StudyList.rt           = resp_time' - OnsetTime';

    % Write the `StudyList` for this round to a .csv file in the local directory "./data"
    writetable(StudyList, fullfile('.','data',['full_recall_study_' subject '_' num2str(list) '_' TimeStamp '.csv']));
    
    % Record
    datadir      = strcat('.', filesep, 'data');
    filename     = sprintf('total-recall_%s_%s_%s.wav', subject, num2str(list), TimeStamp);
    fullfilename = fullfile(datadir, filename);
    audiowrite(fullfilename, recordedaudio, freq);

end