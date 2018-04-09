function [varargout] = generate_lists(listtype, varargin)

switch listtype
    
    case 'practice'
        
        path_to_stim = varargin{1};
        
        Stim_poss    = readtable(path_to_stim);

        %-- Pick a Random Sample of Emotional Words for this
        %   Stim List, which varies based on condition
            
            number_of_stim_to_select = 8;
            selection   = datasample(1:height(Stim_poss), number_of_stim_to_select, 'Replace', false);

            % Assignment Variables
            Word            = table2cell(Stim_poss(selection, {'Word'}));
            Arousal         = table2array(Stim_poss(selection, {'Arousal'}));
            Valence         = table2array(Stim_poss(selection, {'Valence'}));
            EmotionCategory = repmat({'Practice'}, length(Valence), 1);
            listID          = ones(length(Valence), 1);
            roundID       = ones(length(Valence), 1);
            Condition       = repmat(-1, length(Valence), 1);

            
            % Create the Experiment Table
            Experiment  = table(roundID, listID, Word, Arousal, Valence, EmotionCategory, Condition);
            
            % Output Experiment Table
            varargout{1} = Experiment;
        
    case 'experiment'
   
        % Parse Default Input Arguments
        sub          = varargin{1};
        path_to_stim = varargin{2};
        
        % Default Study Settings
        numOfRound         = 4;
        numOfListsPerRound = 4;
        numOfLists         = numOfRound * numOfListsPerRound;
        
        Stim_poss    = readtable(path_to_stim);
        
        % Initalizing variables
        totalTrials     = numOfRound * numOfListsPerRound * 16;
        listID          = zeros(totalTrials, 1);
        roundID         = zeros(totalTrials, 1);
        Word            = cell(totalTrials, 1);
        Arousal         = zeros(totalTrials, 1);
        Valence         = zeros(totalTrials, 1);
        EmotionCategory = cell(totalTrials, 1);
        counter         = 0;

        % Create Conditions, a cell arrary of string specifying which list
        % belongs to which condition. Give the list presentation order a 
        % good randomization.
        Condition = {'allNeutral', 'halfEmotional'};
        Condition = vertcat(repmat(Condition(1), numOfLists/2, 1), ... 
                             repmat(Condition(2), numOfLists/2, 1));
        Condition = Condition(randperm(length(Condition)));

        % reset the Already Assigned filters each round. Note:
        % stimuli may be repeated BETWEEN rounds, but not WITHIN
        % rounds. There is not enough unique stimuli to not
        % repeat for the entire experiment
        %
        % Emotion Category Definitions:
        %   Neutral words have Arousal and Valence between 4 and 6
        %   Emotional words have Arousal above 6 and Valence below 4

        emoAAfilter = Stim_poss.Arousal > 6 & Stim_poss.Valence < 4;
        neuAAfilter = Stim_poss.Arousal < 6 & Stim_poss.Arousal > 4 & Stim_poss.Valence > 4 & Stim_poss.Valence < 6;        
        
        for round = 1:numOfRound                

            for list = 1:numOfListsPerRound % create 8 for each round

                % Advance counter
                counter = counter + 1;

                % Conditions: [A B B A]
                if strcmp(Condition{counter}, 'allNeutral')
                    numOfEmo = 0;
                elseif strcmp(Condition{counter}, 'halfEmotional')
                    numOfEmo = 8;
                end
                numOfNeu = 16 - numOfEmo;

                %-- Pick a Random Sample of Emotional Words for this
                %   Stim List, which varies based on condition

                    selection   = datasample(find(emoAAfilter), numOfEmo, 'Replace', false);

                    % Calculate the position we will place the selection in
                    idx         = (counter-1) * 16 + 1 : (counter-1) * 16 + numOfEmo;

                    % Assignment Variables
                    Word(idx')            = table2cell(Stim_poss(selection, {'Word'}));
                    Arousal(idx')         = table2array(Stim_poss(selection, {'Arousal'}));
                    Valence(idx')         = table2array(Stim_poss(selection, {'Valence'}));
                    EmotionCategory(idx') = repmat({'Emotional'}, length(idx), 1);
                    listID(idx')          = repmat(counter, length(idx), 1);
                    roundID(idx')         = repmat(round, length(idx), 1);

                    % Update the Already Assigned filter to exclude
                    % previously selected stim
                    emoAAfilter(selection) = false;

                %-- Pick a Random Sample of Neutral Words for this
                %   Stim List, which varies based on condition

                    selection   = datasample(find(neuAAfilter), numOfNeu, 'Replace', false);

                    % Calculate the position we will place the selection in
                    idx         = (counter-1) * 16 + 1 + numOfEmo : (counter-1) * 16 + numOfEmo + numOfNeu;

                    % Assignment Variables
                    Word(idx')            = table2cell(Stim_poss(selection, {'Word'}));
                    Arousal(idx')         = table2array(Stim_poss(selection, {'Arousal'}));
                    Valence(idx')         = table2array(Stim_poss(selection, {'Valence'}));
                    EmotionCategory(idx') = repmat({'Neutral'}, length(idx), 1);
                    listID(idx')          = repmat(counter, length(idx), 1);
                    roundID(idx')       = repmat(round, length(idx), 1);


                    % Update the Already Assigned filter to exclude
                    % previously selected stim
                    neuAAfilter(selection) = false;

            end

        end

        % Tag on subjectID
        subjectID   = repmat({sub}, length(Word), 1);

        % Expand Condition to fit in the table
        Condition   = repelem(Condition, 16);
        
        % Create the Experiment Table
        Experiment  = table(subjectID, roundID, listID, Word, Arousal, Valence, EmotionCategory, Condition);

        % Randomize the Order of the Stimuli with a each list

        for ll = unique(Experiment.listID)'

            filt = Experiment.listID == ll;

            Experiment(filt,:) = RandomizeRows(Experiment(filt, :));

        end

        % Output Experiment Table
        varargout{1} = Experiment;
        
end


end