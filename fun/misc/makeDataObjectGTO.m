function makeDataObject
load('/var/folders/5k/f4sltq2578qcb0_1q2bn7dqh0000gp/T/com.apple.mail.drag/ErrorResults_Force.mat')
groups=['OA';'OG';'YA';'YG'];
for i=1:4
    eval(['n=size(SMatrix.',groups(i,:),'.IDs,1)']);
    eval(['subj=SMatrix.',groups(i,:),'.IDs(:,1);']);
    Subject
    ignoreMatFlag=0;
    for s=1:n
        %
        %         eval([' load(''',subj{s},'params.mat'') ']);
        try
            load([Subject '.mat'])
            saveloc = [];
        catch
            try
                load([Subject '/' Subject '.mat'])
                saveloc=['/Volumes/TorresShared/Shared/Harrison/Overground Study/DATA/Old Abrupt'];
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
        
    end
end
end