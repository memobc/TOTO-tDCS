function [varargout] = generate_lists(listtype, varargin)

switch listtype
    
    case 'practice'
        
        path_to_stim = varargin{1};
        
        Stim_poss    = readtable(path_to_stim);

        %-- Pick a Random Sample of Emotional Words for this
        %   Stim List, which varies based on condition

            selection   = datasample(1:height(Stim_poss), 16, 'Replace', false);

            % Assignment Variables
            Word            = table2cell(Stim_poss(selection, {'Word'}));
            Arousal         = table2array(Stim_poss(selection, {'Arousal'}));
            Valence         = table2array(Stim_poss(selection, {'Valence'}));
            EmotionCategory = repmat({'Practice'}, length(Valence), 1);
            listID          = ones(length(Valence), 1);
            sessionID       = ones(length(Valence), 1);
            Condition       = repmat(-1, length(Valence), 1);

            
            % Create the Experiment Table
            Experiment  = table(sessionID, listID, Word, Arousal, Valence, EmotionCategory, Condition);
            
            % Output Experiment Table
            varargout{1} = Experiment;
        
    case 'experiment'
   
        % Parse Default Input Arguments
        sub          = varargin{1};
        path_to_stim = varargin{2};
        
        Stim_poss    = readtable(path_to_stim);
        
        %-- Create lists for 5 sessions of 8 lists of 16 words
        %   AKA 5*8*16 = 1792 words
        %   AKA 5*8    = 40 lists
        
            % Initalizing variables
            totalTrials     = 640;
            listID          = zeros(totalTrials, 1);
            sessionID       = zeros(totalTrials, 1);
            Word            = cell(totalTrials, 1);
            Arousal         = zeros(totalTrials, 1);
            Valence         = zeros(totalTrials, 1);
            Condition       = cell(totalTrials, 1);
            EmotionCategory = cell(totalTrials, 1);
            counter         = 0;
            
            for session = 1:5
                
                % reset the Already Assigned filters nneach session
                % Emotion Category Definitions:
                %   Neutral words have Arousal and Valence between 4 and 6
                %   Emotional words have Arousal above 6 and Valence below 4
                emoAAfilter = Stim_poss.Arousal > 6 & Stim_poss.Valence < 4;
                neuAAfilter = Stim_poss.Arousal < 6 & Stim_poss.Arousal > 4 & Stim_poss.Valence > 4 & Stim_poss.Valence < 6;
                
                for cond = {'2' '8'} % 2 or 8 emotional stimuli
                
                    for list = 1:4 % create 8 lists of each condition

                        % Advance counter
                        counter = counter + 1;
                        
                        % Condition Specifics
                        if strcmp(cond, '2')
                            numOfEmo = 2;
                        elseif strcmp(cond, '8')
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
                            sessionID(idx')       = repmat(session, length(idx), 1);
                            Condition(idx')       = repmat(cond, length(idx), 1);
                            
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
                            sessionID(idx')       = repmat(session, length(idx), 1);
                            Condition(idx')       = repmat(cond, length(idx), 1);
                        
                        
                            % Update the Already Assigned filter to exclude
                            % previously selected stim
                            neuAAfilter(selection) = false;

                    end
                    
                end
                
            end
            
            % Tag on subjectID
            subjectID   = repmat({sub}, length(Word), 1);
            
            % Create the Experiment Table
            Experiment  = table(subjectID, sessionID, listID, Word, Arousal, Valence, EmotionCategory, Condition);
            
            % Randomize the Order of the Stimuli with a each list
            for ll = unique(Experiment.listID)'
                
                filt = Experiment.listID == ll;
                
                Experiment(filt,:) = RandomizeRows(Experiment(filt, :));
                
                idxs = find(filt);
                
                while strcmp(Experiment.EmotionCategory(idxs(1)), 'Negative') && strcmp(Experiment.Condition(idxs(1)), '2')
                    
                    filt = Experiment.listID == ll;

                    Experiment(filt,:) = RandomizeRows(Experiment(filt, :));

                    idxs = find(filt);                
                end
                
            end
            
            % Output Experiment Table
            varargout{1} = Experiment;
        
end


end