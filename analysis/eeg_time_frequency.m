function eeg_time_frequency()
%%%% EEG Time Frequency Analysis of the TOTO-tDCS Data %%%%

% turn the annoying MATLAB warnings off
warning('OFF', 'all')

% add EEGLAB and Feildtrip to path; start EEGLAB
if isempty(which('eeglab'))
    addpath('/Users/kylekurkela/Documents/MATLAB/software/toolboxes-eeg/eeglab14_1_1b');
end
eeglab()
if isempty(which('ft_freqanalysis'))
    addpath(genpath('/Users/kylekurkela/Documents/MATLAB/software/toolboxes-eeg/fieldtrip'));
end
rmpath(genpath('/Users/kylekurkela/Documents/MATLAB/software/toolboxes-fmri/spm12'));

% subjects
subjects = 1:36;
datapath = '/Volumes/GoogleDrive/My Drive/Behavioral Data/TOTO-tDCS/derivatives/';

% Add SPM and remove it because it will "confuse Fieldtrip"
addpath(genpath('/Users/kylekurkela/Documents/MATLAB/software/toolboxes-fmri/spm12'));
setfiles     = cellstr(spm_select('FPListRec', datapath, '.*\.set'));
setfilesdirs = cellfun(@(x) fileparts(x), setfiles, 'UniformOutput', false);
resultfiles  = cellstr(spm_select('FPListRec', datapath, '.*_freq\.mat'));
rmpath(genpath('/Users/kylekurkela/Documents/MATLAB/software/toolboxes-fmri/spm12'));

% for each subject, for each session
for isub = subjects

    for ises = 1:2

        % update user
        fprintf('\nsub-s%03d\n', isub);
        fprintf('\nsess-%02d\n', ises);
        
        % is there a result file for this subject/session? If there is,
        % continue
        sub  = sprintf('sub-%03d', isub);
        ses  = sprintf('ses-%02d', ises);
        subF = grepl(resultfiles, sub);
        sesF = grepl(resultfiles, ses);
        assert(length(find(subF & sesF)) < 2, 'more than one match')
        if any(subF & sesF)
            continue
        end
       
        % is there a set file for this subject/session? If there is NOT,
        % continue
        sub  = sprintf('s%03d', isub);
        ses  = sprintf('[Ss]es-?%d', ises);
        subF = grepl(setfilesdirs, sub);
        sesF = grepl(setfilesdirs, ses);
        assert(length(find(subF & sesF)) < 2, 'more than one match')
        if ~any(subF & sesF)
            continue
        end
        [filepath, filename, ext]   = fileparts(setfiles{subF & sesF});

        % load data
        EEG  = pop_loadset([filename ext], filepath);
        data = eeglab2fieldtrip(EEG, 'preprocessing', 'none');

        % configurations for analysis
        cfg            = [];
        cfg.method     = 'mtmconvol';
        cfg.taper      = 'hanning';
        cfg.output     = 'pow';
        cfg.channel    = {'all', '-F4'};
        cfg.foi        = 2:2:30;
        cfg.t_ftimwin    = ones(length(cfg.foi),1).*2;
        cfg.toi          = 'all';

        % run time frequency analysis
        [freq] = ft_freqanalysis(cfg, data);

        % a visual
        cfg = [];
        zmax = prctile(reshape(freq.powspctrm, 1, numel(freq.powspctrm)), 95);
        cfg.zlim = [0, zmax];
        figure
        ft_singleplotTFR(cfg, freq);
        
        % labels
        xlabel('Time (sec)')
        ylabel('Frequency')
        c = colorbar();
        c.Label.String = 'Power';
        
        % add highlight
        ylimits = ylim();
        top = ylimits(2);
        bottom = ylimits(1);
        x = [0 0 300 300];
        y = [bottom top top bottom];
        patch(x, y, 'red', 'FaceAlpha', .2)
        
        % save data and plots

        savepath = filepath;
        filename = sprintf('sub-%03d_ses-%02d_power-sepecturm.fig', isub, ises);
        savefig(gcf, fullfile(savepath, filename));
        
        filename = sprintf('sub-%03d_ses-%02d_freq.mat', isub, ises);
        save(fullfile(savepath, filename), 'freq');

    end
end

%% subfunctions

    function bool = grepl(cellarray, pattern)
        % search the cellarray for occurances of the regular expression
        % pattern
        result = regexp(cellarray, pattern);
        bool   = ~cellfun(@isempty, result);
    end

end