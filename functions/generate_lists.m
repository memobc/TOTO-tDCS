function [varargout] = generate_lists(listtype, varargin)

switch listtype
    
    case 'practice'
        
        varargout{1}  = readtable([pwd filesep 'stim' filesep 'practice.csv']);
        varargout{2}  = readtable([pwd filesep 'stim' filesep 'practice_recog.csv']);
        
    case 'study'
   
        % Parse Default Input Arguments
        if nargin == 2
            sub          = varargin{1};
            path_to_stim = [pwd filesep 'stim' filesep 'stimuli.csv'];
        elseif nargin == 3
            sub           = varargin{1};
            path_to_stim  = varargin{2};
        end
        
        Stim_poss = readtable(path_to_stim);
        
        %-- Create Place and Person "Fans" using the method described in
        %   Radvansky, Speiler, and Zacks (1993); see Appendix B
        
            % Unique Locations and People
            Locations = unique(Stim_poss.Location);
            Subjects  = unique(Stim_poss.Subject);
            
            % This must be the case
            assert(length(Locations) == length(Subjects))
            numberOfPairs = length(Locations);

            % Randomly Order them for each participant
            Locations = Locations(randperm(numberOfPairs));
            Subjects  = Subjects(randperm(numberOfPairs));

            % Save Out Design Matrix for this Subject
            subj       = repmat({sub}, numberOfPairs, 1);
            SubjectID  = {'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l'}';
            LocationID = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L'}';
            
            DesignMatrix = table(subj, Subjects, SubjectID, Locations, LocationID);
            
            writetable(DesignMatrix, [pwd filesep 'designs' filesep sub '.csv'])
            
        %-- Algorithm

            % Initalize
            indices = zeros(1, 18); % hardcorded, based on Radvansky, Speiler, and Zacks (1993)
        
            %--Find the indices of all the stimuli we want to pull from the
            %  Stim_poss table

                % According to the table in Radvansky et al. 1993, we want all
                % in place pairs (i.e., aA, bB, cC ...etc.)

                for p = 1:numberOfPairs

                    % Find all of the aA bB cC ... sentences
                    logical_vector  = strcmp(Stim_poss.Subject, Subjects(p)) & strcmp(Stim_poss.Location, Locations(p));
                    indices(p)      = find(logical_vector);

                end
                
                % Also according to Radvansky et al. 1993, we want iG, jH, kE,
                % kG, lF, lH

                matches = {[9 7], ... % iG
                           [10 8], ... % jH
                           [11 5], ... % kE
                           [11 7], ... % kG
                           [12 6], ... % lF
                           [12 8]};    % lH
                
                for m = 1:length(matches)
                   
                    % Find the iG, jH, kE, kG, lF, lH sentences
                    logical_vector  = strcmp(Stim_poss.Subject, Subjects(matches{m}(1))) & strcmp(Stim_poss.Location, Locations(matches{m}(2)));
                    indices(numberOfPairs + m)      = find(logical_vector);
                    
                end

                % Create Study table
                Study = Stim_poss(indices', :);

                % Add Study Specific Variables
                Study.DesignIndex = {'aA' 'bB' 'cC' 'dD' 'eE' 'fF' 'gG' 'hH' 'iI' 'jJ' 'kK' 'lL' 'iG' 'jH' 'kE' 'kG' 'lF' 'lH'}';
                Study.SubjectFan  = [1 1 1 1 1 1 1 1 2 2 3 3 2 2 3 3 3 3]';
                Study.LocationFan = [1 1 1 1 2 2 3 3 1 1 1 1 3 3 2 3 2 3]';
                Study.Condition   = {'SL' 'SL' 'None' 'ML' 'SL' 'SL' 'SL' 'SL' 'ML' 'ML' 'ML' 'ML' 'None' 'None' 'None' 'None' 'None' 'None'}';
                Study.DesignCell  = vertcat([1 1], [1 1], [1 1], [1 1], [1 2], [1 2], [1 3], [1 3], [2 1], [2 1], [3 1], [3 1], [2 3], [2 3], [3 2], [3 3], [3 2], [3 3]);
                
                % Output
                varargout{1} = Study;
                
    case 'test'
        
        % Parse Input Arguments
        Study          = varargin{1};
        
        % Counter
        count = 0;
        
        %-- Create Questions
        
        for sub = unique(Study.Subject)'
            count = count + 1;
            subject{count}  = sub{:};
            question{count} = sprintf('Where is the %s?', lower(sub{:}));
        end
        
        for loc = unique(Study.Location)'
            count = count + 1;
            location{count - length(unique(Study.Subject))} = loc{:};
            question{count} = sprintf('What is in the %s?', lower(loc{:}));
        end

        %-- Create Test List
        Test = table;
        
        Test.Question  = question';
        Test.Noun      = vertcat(subject', location');
        Test.Type      = cell(height(Test), 1);
        ind = 1:length(subject);
        Test.Type(ind) = {'Subject'};
        ind = length(subject)+1:length(subject)+length(location);
        Test.Type(ind) = {'Location'};      
        
        varargout{1} = Test;
        
    case 'recog'
        
        % Parse Input Arguments
        Study          = varargin{1};
        
        % Initalize Recognition List and add an ANSWER variable
        Recognition        = Study;
        Recognition.Answer = repmat({'STUDIED'}, height(Recognition), 1);
        
        
        %-- Create a single foil sentence for each target sentence by
        %   recombing sentences with each cell of the design matrix
        
        count = 0;
        
        % for each cell of the design matrix...
        for cel = unique(Recognition.DesignCell, 'rows')'
            
            % Create a filter for this cell
            filter  =  repmat(cel', height(Recognition), 1) == Recognition.DesignCell;
            filter  =  filter(:,1) & filter(:,2);

            
            % For the special case when there are 4 pairs in a cell...
            if length(find(filter)) == 4
                
                indices = find(filter);
                indices = indices(randperm(length(indices)));
                
                count = count + 1;
                Subject{count}      = Recognition.Subject{indices(1)};
                Location{count}     = Recognition.Location{indices(2)};
                Sentence{count}     = sprintf('The %s is in the %s.', lower(Subject{count}), lower(Location{count}));
                DesignCell(count,:) = cel';
                
                count = count + 1;
                Subject{count}      = Recognition.Subject{indices(2)};
                Location{count}     = Recognition.Location{indices(1)};
                Sentence{count}     = sprintf('The %s is in the %s.', lower(Subject{count}), lower(Location{count}));
                DesignCell(count,:) = cel';
                
                count = count + 1;
                Subject{count}      = Recognition.Subject{indices(3)};
                Location{count}     = Recognition.Location{indices(4)};
                Sentence{count}     = sprintf('The %s is in the %s.', lower(Subject{count}), lower(Location{count}));
                DesignCell(count,:) = cel';
                
                count = count + 1;
                Subject{count}      = Recognition.Subject{indices(4)};
                Location{count}     = Recognition.Location{indices(3)};
                Sentence{count}     = sprintf('The %s is in the %s.', lower(Subject{count}), lower(Location{count}));                
                DesignCell(count,:) = cel';
                
            else % otherwise...
                
                indices = find(filter);
                
                count = count + 1;
                Subject{count}      = Recognition.Subject{indices(1)};
                Location{count}     = Recognition.Location{indices(2)};
                Sentence{count}     = sprintf('The %s is in the %s.', lower(Subject{count}), lower(Location{count}));
                DesignCell(count,:) = cel';
                
                count = count + 1;
                Subject{count}      = Recognition.Subject{indices(2)};
                Location{count}     = Recognition.Location{indices(1)};
                Sentence{count}     = sprintf('The %s is in the %s.', lower(Subject{count}), lower(Location{count}));                
                DesignCell(count,:) = cel';
                
            end
            
        end
        
        % Create the Foils List
        Foils = table(Sentence', Subject', Location', DesignCell, ...
                      'VariableNames', {'Sentence' 'Subject' 'Location', 'DesignCell'});
        
        % Add variables to Foils List
        Foils.DesignIndex = repmat({'NA'}, height(Foils), 1);
        Foils.SubjectFan  = repmat(-1, height(Foils), 1);
        Foils.LocationFan = repmat(-1, height(Foils), 1);
        Foils.Condition   = repmat({'NA'}, height(Foils), 1);
        Foils.Answer      = repmat({'NOT STUDIED'}, height(Foils), 1);
        
        % Add Foils List to Recognition List
        varargout{1}     = vertcat(Recognition, Foils);
        
end


end