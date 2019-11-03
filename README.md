# `ParaJob` - run parameter studies in parallel without the hassle

`ParaJob` is a set of functions written in Matlab. It allows you to run a lot of computations with varying parameters (such as convergence studies in the FEM) in parallel, with all the bugs and problems already worked out for you. 

Specifically, `ParaJob`,
  - runs jobs in parallel (as separate Matlab instances, this means no Parallel
  toolbox license is needed, things like global variables still work and typical 
  limitations of Matlab's `parfor`-loop do not apply.)
  - captures program output in a log file for each instance,
  - provides an interface to 
    - launch a given number of instances
    - continuously print current progress
  - catches runtime errors gracefully and saves a stack-trace that helps with debugging 
  - balances distributes load such that the given job will be finished as soon as possible


### Demo-Run

To start one of the provided examples, launch `ParaJob` from the command line:
````
./paraJobLauncher.sh <studyID> <NumInstances> <RunMode> 
````
This will start the specified number of instances, which in turn will run computations in the job queue. The results of each computation are stored in `.mat` files that can be collected afterwards by custom visualization routine from within Matlab.

For longer jobs, it one might want to get an overview of the current tasks:
````
./paraJobMonitor <studyID>
````

### Running your own studies

New jobs are defined in the file `pjParamSets.m` For a new job, one essentially needs to define these fields:
````
Param.getJobArgs = @(i) {i, 1/i};
Param.getJobFunc = @(i) @demoFunc ;
Param.getJobFileName = @(i) [Param.ResultsPath sprintf('demores_i%i.mat',i)];
Param.nJ = 2;
Param.saveRes = true;
````
where the first three fields are function handles that return data for a given job-ID.

What happens during execution of each job, is that the `jobFunc` is called with the specified `jobArgs`. The output of the `jobFunc` will then be saved in the `jobFileName`:
````
res = jobFun(jobArgs{:});
save(res, jobFileName);
````

Going back to the definition of a study, the fields `.get___` are responsible  to deliver the correct `jobFunc`, `jobArgs` and `jobFileName` for the given 
job-ID respectively:
`getJobArgs` is a function handle that returns the arguments for the given job-ID as a struct.
`getJobFunc` a function handle that returns the function handle to be called for the given job-ID
`getJobFileName` accordingly is responsible for returning a filename where the results of the given job-ID are to be stored.
`nJ` is just the number of jobs in the given study. (job-IDs range from `1` to `nJ`.)
`saveRes` specifies if the output shall be saved at all. (Sometimes the called function handles the results-saving on their on)


#### Creating `JobArgs`
Note: For parameter studies (where computations are run with all permutations of certain parameters, in the FEM these could be variation of element size, polynomial degree, element class), the function `serializeArguments()` might be useful. See the documentation in the function header for further details.







