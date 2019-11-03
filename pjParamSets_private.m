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
        
    elseif StudyParamSet == 101 || StudyParamSet == 107
        % SMQLin: study variants of linear surface meshing options (eg. AF yes/no,
        % post-smoothing ...)
        redefCheck(Param);
        
        if StudyParamSet == 107
            SubSet = 1;
        else
            SubSet = 0;
        end
        
        [~, pjParam] = LSM3d_SMQLin_StudyParam([],[],SubSet);
        
        Param.getJobArgs = pjParam.getJobArgs;
        Param.getJobFunc = pjParam.getJobFunc;
        Param.getJobFileName = pjParam.getJobFileName;
        Param.nJ = pjParam.nJ;        
        Param.saveRes = pjParam.saveRes;
        
    elseif any(StudyParamSet == [102 103 106 108])
        % SMQHO: study variants of higher-order surface meshing options 
        % (eg. which lifting works best)
        redefCheck(Param);
        
        if StudyParamSet == 102
            [~, pjParam] = LSM3d_SMQHO_StudyParam(0);
        elseif StudyParamSet == 103 % used in P3/SurfMeshing_IMR
            [~, pjParam] = LSM3d_SMQHO_StudyParam(1);
        elseif StudyParamSet == 106 % only G24.
            [~, pjParam] = LSM3d_SMQHO_StudyParam(2);
        elseif StudyParamSet == 108 % only G1, various LCs
            [~, pjParam] = LSM3d_SMQHO_StudyParam(3);
        end
        
        Param.getJobArgs = pjParam.getJobArgs;
        Param.getJobFunc = pjParam.getJobFunc;
        Param.getJobFileName = pjParam.getJobFileName;
        Param.nJ = pjParam.nJ;
        Param.saveRes = pjParam.saveRes;
        
        
    elseif any(StudyParamSet == [104 105 109])
        % VMQ: study HO volume meshing in general
        redefCheck(Param);
        
        if StudyParamSet == 104
            [~, pjParam] = LSM3d_VMQ_StudyParam([]);
        elseif StudyParamSet == 105
            [~, pjParam] = LSM3d_VMQ_StudyParam(1);
        elseif StudyParamSet == 109
            [~, pjParam] = LSM3d_VMQ_StudyParam(2);
        end
        
        Param.getJobArgs = pjParam.getJobArgs;
        Param.getJobFunc = pjParam.getJobFunc;
        Param.getJobFileName = pjParam.getJobFileName;
        Param.nJ = pjParam.nJ;
        Param.saveRes = pjParam.saveRes;
        
        
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
