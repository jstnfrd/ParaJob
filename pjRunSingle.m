function pjRunSingle(iJ, StudyParamSet)
    % run a specific job-iD directly
    
    Param = pjParamSets(StudyParamSet);
    
    
    Func = Param.getJobFunc(iJ);
    Args = Param.getJobArgs(iJ);
    FileName = Param.getJobFileName(iJ);
    
    fprintf('** starting job %i, call: \n%s\n', iJ, pjFormatFunctionCall(Func, Args));
    
    Res = Func(Args{:});
    if Param.saveRes
        save(FileName, 'Res', '-v7.3');
    end
    
    
end