function updateParams(Subject,ignoreMatFlag)
%UPDATEPARAMS   recomputes parameters and saves ne subject file(s).
%Designed for batch re-processing.
%   updateParams(Subject) recomputes the adaptation 
%   parameters and overwrites the (Subject).mat and
%   (Subject)params.mat files if Subject is a sting 
%   containing a subject ID for which a .mat file
%   exists either in the current working directory
%   or in an folder named after the same subject ID.
%
%   updateParams(Subject,1) Only overwrites the 
%   (Subject)params.mat file. Use only when changes
%   to calcExperimentalData have been made.
%   
%   See also calcParameters, experimentData.recomputeParameters, experimentData.makeDataObj.

try
    load([Subject '.mat'])
    saveloc = [];
catch
    try
        load([Subject '\' Subject '.mat'])
        saveloc=[Subject '\'];
    catch
        ME=MException('makeDataObject:loadSubject','The subject file could not be loaded, try changing your matlab path.');
        throw(ME)
    end
end

trials=cell2mat(expData.metaData.trialsInCondition);

if nargin<2 || ignoreMatFlag~=1   
    expData.recomputeParameters; 
    save([saveloc Subject '.mat'],'expData'); %overwrites file
end
adaptData=expData.makeDataObj;
save([saveloc Subject 'params.mat'],'adaptData'); %overwrites file

end