function init_psychtoolbox(DBmode)



%%
%==========================================================================
%                               Misc
%==========================================================================

% Check for Opengl compatibility, abort otherwise
AssertOpenGL;

% Reseed the random-number generator for each Experiment
rng('shuffle', 'v5uniform');

% Turn off the Sync Tests, the visual debugging and warnings and general
% verbosity of PTB
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);

% Prevent Keystrokes from being entered into MATLAB command and editor 
% windows
ListenChar(2);

% Hide the Mouse Cursor
HideCursor;

% Make sure keyboard mapping is the same on all supported operating 
% systems
KbName('UnifyKeyNames');


%%
%==========================================================================
%							PTB Screen Settings
%==========================================================================

% Get screenNumber of stimulation display, and choose the maximum index, 
% which is usually the right one.
screens      = Screen('Screens');
screenNumber = max(screens);

global X Y W pahandle freq

% Open a double buffered fullscreen window on the stimulation screen
% 'screenNumber' and use background color specified in settings
% 'w' is the handle used to direct all drawing commands to that window
% 'wRect' is a rectangle defining the size of the window. See "help 
% PsychRects" for help on such rectangles
%     W = Screen('OpenWindow', screenNumber, backgroundColor);

if strcmp(DBmode, 'y')
    W = Screen('OpenWindow', screenNumber, 128, [0 0 1000 1000]); % Smaller screen for testing/debugging
else
    W = Screen('OpenWindow', screenNumber, 128); % Fullscreen
end

% How large is this window, in pixels?
[X, Y] = Screen(W, 'WindowSize');

% Set Default Text Size for this Window
Screen('TextSize', W, 30);

%-- Psych Sound

% Close all PTB audio devices, JUST in case there is one already open.
PsychPortAudio('Close');

% Initialize Psych Sound
InitializePsychSound;

% Open the default audio device [], with mode 2 (== Only audio capture),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of 44100 Hz and 2 sound channels for stereo capture.
% This returns a handle to the audio device:
freq = 44100;
pahandle = PsychPortAudio('Open', [], 2, 0, freq, 1);

% Preallocate an internal audio recording buffer with a capacity of 75
% seconds.
PsychPortAudio('GetAudioData', pahandle, 75);

%%
%====================================================================================
%							Other Settings
%====================================================================================

% Set priority for script execution to realtime priority
Priority(MaxPriority(W));

% If we are using a Windows machine, hide the task bar
if strcmp(computer,'PCWIN') == 1
    ShowHideWinTaskbarMex(0);
end

end