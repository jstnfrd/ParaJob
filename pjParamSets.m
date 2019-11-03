function Param = pjParamSets(StudyParamSet)
    % get a set of study parameters
    
    % defaults
    Param.ResultsPath = 'Modules/ParaJob/Res/';
    Param.StatusFile = [Param.ResultsPath sprintf('JobStatus_%03i.mat', StudyParamSet)];
    Param.StatusFileTmp = [Param.ResultsPath sprintf('JobStatus_%03i_temp.mat', StudyParamSet)];
    Param.getJobData = @(i) i;
    Param.nJ = 0;
    

    if  StudyParamSet == 0
        % dummy func a.k.a example set
        
        Param.getJobArgs = @(i) {i, 1/i};
        Param.getJobFunc = @(i) @demoFunc ;
        Param.getJobFileName = @(i) [Param.ResultsPath sprintf('demores_i%i.mat',i)];
        Param.nJ = 2;
        Param.saveRes = true;
        
    elseif StudyParamSet == 1
        % this is the place to define your own parameter studies.
        
    elseif isempty(StudyParamSet)
        % should not happen
        error('StudyParamSet was not defined')
    end

    

    
end

function redefCheck(Param)
    assert(Param.nJ == 0, 'Param has aldready been set. maybe StudyParamSet defined multiple times?')
end

function r = demoFunc(a,b)
    fprintf('hello, %i, %i\n', a,b)
    r = a*b;
    assert(a ~= 1, 'Oops, an artificial failure!')
end

%{
function JobData = getJobData(Func, ArgMat, TestCase, id)
    % template function to return job-data 
    
    JobData.Fun = Func;
    JobData.Args = ArgMat(id,:);
    JobData.FileName = sprintf('Res_tc%i_j%i.mat', TestCase, id);
end
%}
