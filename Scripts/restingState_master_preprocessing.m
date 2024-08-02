function spm_master_batch_preprocessing()
% spm_master_batch() example
% spm_master_batch is the entry function for running an SPM job on 
% a structured dataset. To run this master batch you should:
% 1) Define parameter sets and symbols that define the structure of the dataset.
% 2) Initialise the undefined job parameters in JobFunction()
% All relevant lines are marked with: {{{ CONFIGURE BEGIN ...    }}} CONFIGURE END
%
% This file requires the matlab toolbox spmwrapperlib.
% Created 2011-08-22 by Paul Groot
% TODO list below...

    clc % remove this if you don't want to clear command window history on each call

  %% start with a few directory definitions
    % {{{ CONFIGURE BEGIN
    this_dir = fileparts(mfilename('/data/mboger/Motion Control Test/scripts/Condidence/Preprocessing/')); % location of this script
    root_dir = '/data/mboger/Motion Control Test/Experimental';   % location of dataset, without trailing slash
    spmwrapperlib_path = fullfile('/data/mboger/Motion Control Test/','spmwrapperlib'); % location of our toolbox
    % }}} CONFIGURE END
    
    addpath(spmwrapperlib_path);
    
    %% make sure the spmwrapperlib toolbox functions are available
    if ~exist('LoopDB.m','file')
        error('You probably forgot to add spmwrapperlib to the Matlab path')
    end

    %% check if SPM toolbox version; optionally you can supply the location
    % of your SPM directory as argument.
    [spm_dir spm_version] = CheckSPM('FMRI'); % TODO: spm initialisation
 
    
    %% 1a) Define dynamic parameter sets
    % Define the parameter sets that should be iterated to run individual jobs.
    % The loopDB function below will go through all possible combinations
    % of the defined sets and call JobFunction() for each iteration. 
    % The names of the sets are arrbitrary, but the values should be cell arrays {}.
    % The paramter sets can be used as symbols in parameter definitions below
    % by using the <backet> syntax: 'subject number: <SUBJECT>'.
    % The <symbol> will be replaced with the acutual value of the running iteration
    % (i.e. resp, 'subject number: PP01', 'subject number: PP02', ...)
    % {{{ CONFIGURE BEGIN
    db.sets.STUDY   = {'Confidence'};
    % missing: 2110, 2128 onwards until 3102, 4116, 3109 (permission
    % denied error), 3112 onwards, '3113','3114','3115','3118','3119','3120','3122','3123','3125','3126','3127','3129','3130','3131','3132',
    % '4119', '4128' (permission denied error), '4139', '4144' (permission
    % denied error
    % 
    % missing subjects due to missing files unless noted otherwise
    db.sets.SUBJECT = {'4124', '4125', '4126', '4127', '4134', '4135', '4136',
        '4139', '4140', '4141', '4142', '4143', '4144', '4145', '4146', 
        '4147', '4148', '4149', '4150', '4151', '4152', '4153', '4154'};
   % rsdirs = glob('/data/shared/confidence/Experimental/*/RestingState/');
   % subIDs = {};
    % for idx = 1:length(rsdirs); subID = char(cell2mat(rsdirs(idx))); subID = subID(38:41); subIDs{end+1} = subID; end
    % END'103','104','105','106','107','108','109','110','111','112','113','114','115','117','118','119','120','121','122','123','124',125','126','201','202','203','204','205','206','208','209','210','211','212','213','214','215','217','218','219','221','222','223','224','301','302','304','306','307','308','310','311','312','313','314','315','316','317','318','320','322','325'

    %% 1b) Define symbols for static parameters. 
    % You can use the parameter sets defined in 1a) as symbol name using the <>-syntax. 
    % You can also use existing symbols in new symbol definitions. 
    % N.B. Use a forward slash '/' as directory separator or the fullfile function
    %      if you would like to be compatible with Windows and Linux systems. 
    % N.B. It is also possible to define non-text values as symbols (i.e. [1 -1]), but
    %      such symbols cannot be used in symbol replacement with the <>-syntax.
    % {{{ CONFIGURE BEGIN
    db.symbols.ROOT             = root_dir;
    db.symbols.SPMDIR           = spm_dir;
    db.symbols.JOBDIR           = '/data/mboger/Motion Control Test/scripts/Confidence/Preprocessing/Realignment Only/';
    db.symbols.JOBFILE          = 'preprocessing_job.m'; % 
    db.symbols.SUBJECTDIR       = '<ROOT>/<SUBJECT>';
    db.symbols.ANATDIR          = '<SUBJECTDIR>/';      % 
    db.symbols.FUNCDIR1          = '<SUBJECTDIR>/RestingState/Combined/PAID_data/'; 
    %db.symbols.FUNCDIR2          = '<SUBJECTDIR>/Confidence_2/Combined/PAID_data';
   %db.symbols.FUNCDIR3          = '<SUBJECTDIR>/session3';
    %db.symbols.SESSIONDIR       = '<SUBJECTDIR>/<SESSION>';         % or fullfile('<SUBJECTDIR>','<SESSION>');
    %db.symbols.STATSDIR         = '<ROOT>/<STUDY>/<SESSION>/stats'; % or fullfile('<ROOT>','<STUDY>','<SESSION>','stats');
    %db.symbols.CONDITIONSFILE   = '<SESSIONDIR>/log/conditions.mat'; % 
    %db.symbols.TPMDIR           = '<SPMDIR>/tpm';                   % or fullfile('<SPMDIR>','tpm');
    %db.symbols.TPM_GREY         = '<TPMDIR>/grey.nii';              % or fullfile('<TPMDIR>','grey.nii');
    %db.symbols.TPM_WHITE        = '<TPMDIR>/white.nii';             % or fullfile('<TPMDIR>','white.nii');
    %db.symbols.TPM_CSF          = '<TPMDIR>/csf.nii';               % or fullfile('<TPMDIR>','csf.nii');
    % }}} CONFIGURE END

    %% 1c) Define filesets as regular expressions
    % Filenames should be regular expressions when used with GetImageList3D/4D or spm_select functions.
    % To simplify this, you can use the functions PlainFilename and WildcardFilename if
    % no regular expressions are required. Note that these parameters are case-sensitive.
    % {{{ CONFIGURE BEGIN
    db.symbols.FUNCNAMES = 'M*.nii'; 
    %db.symbols.ANATNAME  = 'comp_<SUBJECT>_WIP_sT1W_3D_TFE_32_channel_SENSE_2_1.nii';     % i.e. regular expression: ^T1\.nii$
    db.symbols.ANATNAME  = '.*\.nii'; 
    %db.symbols.MEANNAME = '^mean*.nii';
    % }}} CONFIGURE END

    %% 1d) Define job file, job function and optional logfile
    % Instead of specifying these parameters here, you can also pass them as additional arguments
    % to LoopDB. However, including them in the structure itself makes it possible to define
    % more then one job in this master batch; i.e. specify jobs as cells: LoopDB( { db1, db2 } )
    % {{{ CONFIGURE BEGIN
    db.jobfn        = @JobFunction;
    db.job          = '<JOBDIR>/<JOBFILE>';   % file path of the jobfile; <SYMBOLS> are allowed
    %db.diaryfile    = '<STATSDIR>/diary.log'; % optional: file path of the logfile; <SYMBOLS> are allowed
    % }}} CONFIGURE END
    
    %% run the job function for each dataset in the database
    LoopDB(db);
%   Alternative: LoopDB(db, fullfile(job_path,job_file), @JobFunction, '<STATSDIR>/diary.log');

end % spm_master_batch


%% ---------------------------------------------------------------------------------------------------------------------------------
% JobFunction(job, symbols)
% This is the function that will be called for each batch iteration (i.e. for each dataset to analyse).
% The basic idea is to initialise all unspecified job parameters and run SPM.


function result = JobFunction(job, symbols)
    % job      - the filename of the SPM job to run
    % symbols  - the symbol table, expanded with actual values for the current iteration

    %% 2a) Collect the filenames of the anatomical, functional scans as cell array's and
    % the 3 tissue probability maps for segmentation.
    % {{{ CONFIGURE BEGIN
    %anat = GetImageList3D(symbols.ANATDIR, PlainFilename(symbols.ANATNAME));
    anat = GetImageList3D(symbols.ANATDIR, symbols.ANATNAME); % Structural 3D
    func1 = GetImageList4D(symbols.FUNCDIR1, WildcardFilename(symbols.FUNCNAMES));
    %func2 = GetImageList4D(symbols.FUNCDIR2, WildcardFilename(symbols.FUNCNAMES));
    %func3 = GetImageList4D(symbols.FUNCDIR3, WildcardFilename(symbols.FUNCNAMES));
    %tpm  = { symbols.TPM_GREY, symbols.TPM_WHITE, symbols.TPM_CSF }; % Tissue Probability Maps; overrule the default values from the batch editor because the spm location might be different on other systems.
    % }}} CONFIGURE END

    %% 2b) optional step
    % although it is possible to create new directories by using BasicIO functions in the batch itself, it is sometimes
    % more convenient to call CreateDir() at this point using the appropriate symbol as argument. The main difference
    % is that CreateDir() also will create non-existing parent directories.
    % CreateDir(symbols.STATSDIR);
    
    %% 2c) Create a cell array for all unspecified job parameters. 
    % Notes: - the order and count of the input-array below, must be exactly the same as the unspecified fields in the job. 
    %        - parameters of type 'cfg_files' (i.e. file and directories) must be specified as cell array of strings.
    %        - parameters of type 'cfg_menu' (i.e. 'secs' or 'scans') must be specified as numeric menu index
    %        - parameters of type 'cfg_entry' are regular vaules (i.e. numeric or text) and don't have to be placed in cell arrays
    %        - to declare non-text symbol values you can do the following
    %          a) just declare the symbol as-is: db.symbol.CONTRAST1 = [1 -1];
    %          b) or, declare the symbol as tekst (db.symbol.CONTRAST1 = '[1 -1]';),
    %             and use eval below to translate: inputs{end+1} = eval(db.symbol.CONTRAST1);
    inputs = {}; % initialise empty cell for collecting the following paramters
    % {{{ CONFIGURE BEGIN
    inputs{end+1} = func1;                      % Realign: Estimate & Reslice: Session - cfg_files
    %inputs{end+1} = func2;                      % Realign: Estimate & Reslice: Session - cfg_files
    %inputs{end+1} = func3;                      % Realign: Estimate & Reslice: Session - cfg_files
    inputs{end+1} = anat;                       % Coregister: Estimate: Source Image - cfg_files
    % }}} CONFIGURE END

 %% run spm job manager
    spm_jobman('serial', job, '', inputs{:});
	
	result = true;
end