function pjManipStatusFile
    % tool to set job-status of specific jobs.
    % (edit this to your needs)
    
    
    StudyParamSet = 103;
    Param = pjParamSets(StudyParamSet);
    StatusFile = Param.StatusFile;
    
    loaded = load(StatusFile);
    jobs = loaded.jobs;
    
    
    for iJ = 1:Param.nJ
        Args = Param.getJobArgs(iJ);
        
        %jsOld = jobs.Status(iJ);
        
        if Args{1} == 3 && Args{2} == 2 && any(Args{3} == [11 21 31 22 32]) && jobs.Status(iJ) ~= 2
            % only re-do undone jobs of that category
            jobs.Status(iJ) = 0;
        else
            % set all other jobs to be finished
            jobs.Status(iJ) = 2;
        end
        
        %fprintf('%i --> %i\n', jsOld, JobStati(iJ))
        
    end
    
    % reset all pending or failed jobs too
    %jobs.Status(jobs.Status == 1 | jobs.Status == -1) = 0; 
    
    save(StatusFile, 'jobs')
end