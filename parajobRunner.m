function parajobRunner(RunMode, StudyParamSet, CurrentInstance)
    % runs whatever jobs the pjJobManager gives it.
    
    global DPRINTF_ON
    DPRINTF_ON = 0;
    
    if nargin < 1 || isempty(RunMode)
        RunMode = 0;
    end
    
    if nargin < 2 || isempty(StudyParamSet)
        StudyParamSet = 0;
    end
    
    Param = pjParamSets(StudyParamSet);
    
    
    switch RunMode
        case 1
            % master:
            % this instance is responsible for creation of the job file
            pjJobManager(StudyParamSet, -1, 1);
            
        case 0
            % slave:
            % wait until JobFile was re-setup by master instance
            pause(.1 + rand(1) * 3);
            
        case 2
            % master: re-set errornous jobs to be undone.
            %
            pjJobManager(StudyParamSet, -1, 2);
            
        otherwise
            error('wrong RunMode');
    end
    
    
    while true
        % get next job
        c = pjJobManager(StudyParamSet, 0);
        if isempty(c)
            break;
        end
        
        %fprintf('** launchStudy job %i started.\n', c)
        
        try
            Func = Param.getJobFunc(c);
            Args = Param.getJobArgs(c);
            FileName = Param.getJobFileName(c);
            
            fprintf('** inst: %i, starting job %i, call: \n%s\n', ...
                CurrentInstance, c, pjFormatFunctionCall(Func, Args));
            
            Res = Func(Args{:});
            if Param.saveRes
                save(FileName, 'Res', '-v7.3');
            end
            
            JobStatus = 2;
            ErrorMsg = '';
        % {    
        catch ME
            % get error message into string:
            warningTxt = sprintf('job %i failed with message: %s\n', c, ME.message);
            warningTxt = [warningTxt 'function call: ' newline ' ' pjFormatFunctionCall(Func, Args) newline]; %#ok<*AGROW>
            warningTxt = [warningTxt sprintf('stacktrace:\n')];
            for i = 1:length(ME.stack)
                st = ME.stack(i);
                warningTxt = [warningTxt sprintf(' %s : %s : %i\n', st.file, st.name, st.line)];
            end
            warning('%s', warningTxt);
            
            FileNameErrorLog = sprintf('%sError_job%i.txt', Param.ResultsPath, c);
            [fileID, msg] = fopen(FileNameErrorLog,'w');
            if fileID > 0
                fprintf(fileID, '%s', warningTxt);
                fclose(fileID);
            else
                error('could not open file %s:\n %s', FileNameErrorLog, msg);
            end
            
            pause(3);

            JobStatus = -1;
            ErrorMsg = ME.message;
            
        end
        % }
        pjJobManager(StudyParamSet, 1, c, JobStatus, ErrorMsg);
    end
    
    fprintf('----------------------------\n')
    fprintf('** launchStudy finished.\n')
end


    
