function jobID = pjJobManager(StudyParamSet, reqType, varargin)
    % handle various requests regarding the job-queue
    %
    % values for reqType:
    %   -1 ... reset StatusFile, arguments: resetMode (1=full reset, 2:only
    %           reset erroneous jobs)
    %    0 ... request a new job, arguments: getErrorJob (boolean, default=0)
    %    1 ... check-in a job result, arguments: jobID, jobStatus
    %    2 ... print job status overview
    %    3 ... print job status details
    %
    % values for JobStati:
    %    0 ... unstarted
    %    1 ... started (pending)
    %    2 ... finished (with success)
    %   -1 ... job failed
    %
    % ---------------------------------------------------------------------
    
    Param = pjParamSets(StudyParamSet);
    
    StatusFile = Param.StatusFile; % file where its actually stored
    StatusFileTmp = Param.StatusFileTmp; % file that we write to if lockfile cmd isnt available
    StatusFileLock = sprintf('%s.lock', StatusFile);
    
    if hasLockfileCmd()
        StatusFileRW = StatusFile;
    else
        StatusFileRW = StatusFileTmp;
    end
    
    
    switch reqType
        case -1
            % reset status file
            
            ensureStatusFile();
            resetMode = varargin{1};
            Jobs = getStatusFile();
            
            if resetMode == 1
                Jobs.Status = zeros(Param.nJ, 1); % 
            elseif resetMode == 2
                Jobs.Status(Jobs.Status ~= 2) = 0;
            else
                error('invalid value for resetMode')
            end
            Jobs.ErrMsg = cell(Param.nJ, 1);
            
            if hasLockfileCmd()
                delete(StatusFileLock);
            else
                delete(StatusFileTmp);
            end
            
            saveStatusFileRaw(Jobs);
            
        case 0
            % request a new job (and mark this job as pending)
            
            Jobs = getStatusFile();
            
            if nargin == 3 && varargin{1} == 1
                % request a failed job
                JobStatus = -1;
            else
                JobStatus = 0;
            end
            
            UnstartedJobs = find(Jobs.Status == JobStatus);
            if ~isempty(UnstartedJobs)
                jobID =  min(UnstartedJobs);
                jobStatusOld = Jobs.Status(jobID);
                Jobs.Status(jobID) = 1;
                fprintf('  checking out job ID: %i, status: %i->%i\n', jobID, jobStatusOld, 1);
            else
                jobID = [];
            end
            
            closeStatusFile(Jobs);
            
        case 1
            %  check-in a job result

            jobID = varargin{1};
            jobStatus = varargin{2};
            ErrMsg = varargin{3};
            Jobs = getStatusFile();
            
            fprintf('  checking in job ID: %i, status: %i->%i\n', jobID, Jobs.Status(jobID), jobStatus);

            Jobs.Status(jobID) = jobStatus;
            Jobs.ErrMsg{jobID} = ErrMsg;
            closeStatusFile(Jobs);

            
        case 2
            % print job status overview
            
            Jobs = getStatusFile();
            closeStatusFile();
            
            % print job status details
            disp('-------------------')
            fprintf('failed jobs:\n')
            FailedJobs = find(Jobs.Status < 0);
            
            for id = FailedJobs(:)'
                Func = Param.getJobFunc(id);
                Args = Param.getJobArgs(id);
                fprintf('% 4i : %s  :  %s\n', id,  pjFormatFunctionCall(Func, Args), Jobs.ErrMsg{id})
            end

            % print summary
            disp('-------------------')
            fprintf('current jobs:\n')
            fprintf('waiting: %i\n', sum(Jobs.Status == 0))
            fprintf(' active: %i\n', sum(Jobs.Status == 1))
            fprintf('   done: %i\n', sum(Jobs.Status == 2))
            fprintf('  error: %i\n', sum(Jobs.Status < 0))
            fprintf('  total: %i\n', numel(Jobs.Status))
            disp('-------------------')
        otherwise
            error('unknown reqType')
    end
    
    

    % --------------------------------------------------------------------

    function jobs = getStatusFile()
        % make sure we get exclusive access to the StatusFile
        
        
        if ~hasLockfileCmd()
            % old-school approach
            
            FailCounter = 0;
            % wait until file is available
            while true
                try
                    success = movefile(StatusFile, StatusFileTmp);
                    if ~success
                        error('could not move file')
                    end
                    
                    load(StatusFileRW, 'jobs');
                    break;
                catch
                    FailCounter = FailCounter + 1;
                    
                    if FailCounter > 0
                        disp(' ... still waiting for StatusFile.')
                    end
                    
                    assert(FailCounter < 51, 'seems like we will never get that file');
                    pause(rand(1));
                end
            end
            
        else
            % use lockfile: if this lock-file exists, someone else is using the
            % file right now. the unix command 'lockfile' will wait in that
            % case to get the file (this command is part of procmail)
            system(sprintf('lockfile %s.lock', StatusFile));
            load(StatusFileRW, 'jobs');
        end
    end
    
    
    function closeStatusFile(jobs)
        % make it available to others again, if needed, update the file.
        
        if nargin == 1
            % actually update file
            save(StatusFileRW, 'jobs')
        end
        
        if ~hasLockfileCmd()
            % move tmp file to main file
            movefile(StatusFileTmp, StatusFile);
        else
            % remove lockfile
            delete(StatusFileLock);
        end
    end
    
    function saveStatusFileRaw(jobs)
        % save status file, bypassing the locking mechanism
        save(StatusFile, 'jobs');
    end
    
    function unlockStatusFile()
        if isfile(StatusFileTmp)
            movefile(StatusFileTmp, StatusFile);
        elseif isfile(StatusFileLock)
            system(sprintf('rm -f %s', StatusFileLock));
        end
    end
    
    function ensureStatusFile()
        unlockStatusFile()
        
        if ~isfile(StatusFile)
            % file does not exist, so create a fresh one.
            jobs.Status = zeros(Param.nJ, 1);
            jobs.ErrMsg = cell(Param.nJ, 1);
            save(StatusFile, 'jobs');
        end
    end
end

function str = formatNumeric(n)
    if abs(floor(n) - n) < 1e-15
        % is almost an integer:
        str = sprintf('%7i', floor(n));
    else
        % assume it isa float:
        str = sprintf('%.1e', n);
    end
end

function res = hasLockfileCmd()
    % determine if the command  'lockfile' is available.
    [s,r] = system('command -v lockfile');
    res = s == 0;
end