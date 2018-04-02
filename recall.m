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

wordTime   = 1;

questTime  = 2;

fixTime    = 1.5; % Long et al use a jittered ITI between 800 and 1200 ms

postFix    = 1.3; % Long et al use a jittered delay between 1200 and 1400 ms

if strcmp(practice, 'y')
    recallTime = 10;
else
    recallTime = 75;
end
    
%-- Initialize Response Recorder Variables

OnsetTime    = zeros(1, height(StudyList));
resp         = cell(1, height(StudyList));
resp_time    = zeros(1, height(StudyList));
    
%-- Establish global variables

global W X Y pahandle freq

%%
%==========================================================================
%				Instructions
%==========================================================================
% Display instructions and wait for a participant's response before 
% continuing. Please see instructions_screen documentation for more 
% details. Written in a for loop to display multiple instructions screens,
% if desired.
    
instructions_screen(instructions, [], YN.auto);

% Send Beginning of List Encoding EEG Marker
mrk=20;
outlet.push_sample(mrk);

%-- Restrict keypresses to buttons needed for task

RestrictKeysForKbCheck([]);
RestrictKeysForKbCheck([KbName('1!'), KbName('2@')]);

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
        
    %-- Word

        % Draw the Memoranda
        DrawFormattedText(W, StudyList.Word{curTrial}, 'center', 'center');
        
        % Flip Screen (see Screen Flip documentation) and Record the Onset
        % Time
        OnsetTime(curTrial) = Screen(W, 'Flip');
        
        % Send Word Onset EEG Marker
        mrk=21;
        outlet.push_sample(mrk);        
        
        % Wait "wordTime"
        WaitSecs(wordTime * fast);
        
    %-- Word + Question
    
        % Draw the Memoranda
        [~, ny, ~] = DrawFormattedText(W, StudyList.Word{curTrial}, 'center', 'center');    
        
        % Draw Study Question (e.g., 'Will this item fit into a shoebox?' 'Does
        % this word refer to something living or not living?')
        [~, ny, ~] = DrawFormattedText(W, 'Does this word refer to something living or not living?', 'center', ny + 200);
        
        % Draw Reponse Options (e.g., '1 = Def New      |     2 = Prob
        % New')
        DrawFormattedText(W, '1 = Living      |     2 = Non-Living', 'center', ny + 100);
        
        % Flip Screen (see Screen Flip documentation) and Record the Onset
        % Time
        OnsetTime(curTrial) = Screen(W, 'Flip');
        
        % Send Question Onset EEG Marker
        mrk=22;
        outlet.push_sample(mrk); 
                
    %-- Record Responses
    
        % reset keypress indicator  
        FlushEvents('keyDown');
        KeyIsDown = 0;
        nopressyet = 1;

        % set response time as onset time and response as NR in case they don't respond
        resp_time(curTrial) = OnsetTime(curTrial);
        resp{curTrial} = 'NR';

        while (GetSecs) < (OnsetTime(curTrial) + questTime * fast)

            [KeyIsDown, secs, keypress]=KbCheck(-1);
            WaitSecs(0.001);    % wait 1 ms before checking the keyboard again to prevent overload

            if KeyIsDown  % if key is pressed, stop recording response

                % Send EEG marker once and only once, for first response
                if secs-OnsetTime(curTrial) > 0.05 && nopressyet==1

                    % Send Response EEG Marker
                    mrk=23;
                    outlet.push_sample(mrk);
                    
                    % reset nopressyet
                    nopressyet = 0;

                    % record response and response time
                    resp{curTrial} = KbName(find(keypress==1));
                    resp_time(curTrial) = secs;
                    
                end  

            end     

        end
        
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

% Timing
recallstart = GetSecs;
time        = recallstart + recallTime * fast;

%-- Audio Recording

% Start audio capture.
PsychPortAudio('Start', pahandle);

% Send Start of Recall EEG Marker
mrk=30;
outlet.push_sample(mrk);

while (time - GetSecs) >= 0
    
    % Directions
    DrawFormattedText(W, sprintf('Recall!\n\n You have %.0f Seconds Left', (time - GetSecs)), 'center', 'center');
        
    % Flip Screen (see Screen Flip documentation)
    Screen(W, 'Flip');

end

% get the audio OUT of the buffer and into a matrix
audiodata = PsychPortAudio('GetAudioData', pahandle);

% Stop audio capture.
PsychPortAudio('Stop', pahandle);

% Send End of Recall EEG Marker
mrk=39;
outlet.push_sample(mrk);

% Reset KbKeys
RestrictKeysForKbCheck([]);

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

switch practice
    
    % only write data if we ARE NOT in practice mode
    case 'n'
        
        % Add data to `StudyList`
        StudyList.ExpOnset     = OnsetTime' - expStart;
        StudyList.RoundOnset    = OnsetTime' - roundStart;
        StudyList.ListOnset    = OnsetTime' - liststart;
        StudyList.resp         = resp';
        StudyList.resp_time    = resp_time' - liststart;
        StudyList.rt           = resp_time' - OnsetTime';

        % the data directory, "./data/sub-<participant_label>/ses-<session_label>/beh"
        datadir      = fullfile('.', 'data', sprintf('sub-%s', subject), sprintf('ses-%02d', session), 'beh');

        % create the data directory if it doesn't already exist
        if ~exist(datadir, 'dir')
            mkdir(datadir)
        end

        % Write the `StudyList` for this list to a .tsv file following BIDS
        % format convention
        filename = sprintf('sub-%s_ses-%02d_task-%s_list-%02d_events.tsv', subject, session, 'study', list);
        fullfilename = fullfile(datadir, filename);
        writetable(StudyList, fullfilename, 'FileType', 'text', 'Delimiter', '\t');

        % Record audio, again following BIDS format
        filename     = sprintf('sub-%s_ses-%02d_task-%s_list-%02d_audio.wav', subject, session, 'recall', list);
        fullfilename = fullfile(datadir, filename);
        nbits        = 16;
        psychwavwrite(transpose(audiodata), freq, nbits, fullfilename);
    
    % if we are just practicing...
    case 'y'

        % How did we do?
        DrawFormattedText(W, 'How did we do?', 'center', 'center');
        Screen(W, 'Flip');
        
        % Replay recorded audio: Open default device for output, push recorded sound
        % data into its output buffer:
        pahandle = PsychPortAudio('Open', [], 1, 0, freq, 1);
        PsychPortAudio('FillBuffer', pahandle, audiodata);

        % Start playback immediately, wait for start, play once:
        PsychPortAudio('Start', pahandle, 1, 0, 1);

        % Wait for end of playback, then stop engine:
        PsychPortAudio('Stop', pahandle, 1);

        % Close the audio device:
        PsychPortAudio('Close', pahandle);        

end