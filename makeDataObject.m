function makeDataObject(Subject,ignoreMatFlag)
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
    for t=trials
       expData.data{t}.adaptParams=calcParameters(expData.data{t}); 
    end
    save([saveloc Subject '.mat'],'expData');
end
adaptData=expData.makeDataObj;
save([saveloc Subject 'params.mat'],'adaptData'); %Saving with same var name
% cd('E:\Exp0002\Subjects\Final matrix subjects')
% save([saveloc Subject 'params.mat'],'adaptData');
end