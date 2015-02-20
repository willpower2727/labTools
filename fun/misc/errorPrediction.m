function Data = errorPrediction(subs)

%these numbers were figured out beforehand as the maximum of th YA subejcts
%for each condition
adaptNum=590;
tmpostNum=443;
tmbaseNum=145;

cond={'TM base','adaptation','TM post'};
i=1;
for s=subs
    load([char(s),'params.mat'])
    for c=cond
        
        SLasymObs=adaptData.getParamInCond('stepLengthAsym',char(c));
        
        %Spatial
        
        u_sF=adaptData.getParamInCond('alphaFast',char(c));
        y_sF=adaptData.getParamInCond('betaFast',char(c));
        u_sS=adaptData.getParamInCond('alphaSlow1',char(c));
        u_sS2=adaptData.getParamInCond('alphaSlow2',char(c));
        y_sS=adaptData.getParamInCond('betaSlow',char(c));
        
        r_sF=abs(mean(adaptData.getParamInCond('betaFast','TM base')./adaptData.getParamInCond('alphaFast','TM base')));
        r_sS=abs(mean(adaptData.getParamInCond('betaSlow','TM base')./adaptData.getParamInCond('alphaSlow1','TM base')));
        
        %Temporal
        
        u_t=adaptData.getParamInCond('stepTimeFast',char(c));
        y_t=adaptData.getParamInCond('doubleSupportFast2',char(c));
        S_t=adaptData.getParamInCond('stanceTimeSlow',char(c));
        % yobs_t=adaptData.getParamInCond('doubleSupportSlow',cond);
        % eObs_t=adaptData.getParamInCond('doubleSupportDiff2',cond);
        T_t=adaptData.getParamInCond('strideTimeSlow',char(c));
        
        r_t=u_t./T_t;
        
        
        %
%         for n=1:(length(u_sF))
%         
%             X1(n)=((y_sF(n)-u_sF(n))/(T_t(n)-u_t(n)+y_t(n)))*(T_t(n)-u_t(n))+u_sF(n);
%             X2(n)=((y_sS(n)-u_sS(n))/S_t(n))*u_t(n)+u_sS(n);
%         
%             SLs=u_sS2(n)-((y_sF(n)-u_sF(n))/(T_t(n)-u_t(n)+y_t(n)))*(T_t(n)-u_t(n))+u_sF(n);
%             SLf=u_sF(n)-((y_sS(n)-u_sS(n))/S_t(n))*u_t(n)+u_sS(n);
%         
%             stepLengthAsym(n)=(SLf-SLs)/(SLf+SLs);
%         
%         end
%         
        for n=1:(length(u_sF)-1)
            
            %spatial
            yhat_sF=-r_sF*u_sF(n);
            yhat_sS=-r_sS*u_sS(n);
            
            e_sF=y_sF(n)-yhat_sF;
            phat_sF=e_sF/(1+r_sF);
            
            e_sS=y_sS(n)-yhat_sS;
            phat_sS=e_sS/(1+r_sS);
            
            uPredict_sF(n+1)=u_sF(n)+phat_sF;
            uPredict_sS(n+1)=u_sS(n)+phat_sS;
            
            %temporal
            
            yhat_t=S_t(n)-u_t(n);
            e_t=y_t(n)-yhat_t;
            phat_t=e_t/T_t(n);
            
            rPredict_t=r_t(n)+phat_t;
            
            uPredict_t(n+1)= rPredict_t*T_t(n+1);
            
            SLs=uPredict_sS(n+1)-((y_sF(n)-u_sF(n))/(T_t(n)-u_t(n)+y_t(n)))*(T_t(n)-u_t(n))+u_sF(n);
            SLf=uPredict_sF(n+1)-((y_sS(n+1)-uPredict_sS(n+1))/(S_t(n+1)))*uPredict_t(n+1)+uPredict_sS(n+1);
            
            stepLengthAsym(n)=(SLf-SLs)/(SLf+SLs);
            
        end
        
      
        condition=char(c);
        if strcmp(condition,'adaptation')
            Data.(condition(ismember(condition,['A':'Z' 'a':'z' '0':'9'])))(i,1:adaptNum)=stepLengthAsym(1:adaptNum);
            Data.([condition(ismember(condition,['A':'Z' 'a':'z' '0':'9'])) 'obs'])(i,1:adaptNum)=SLasymObs(1:adaptNum);            
        elseif strcmp(condition,'tm post')
            Data.(condition(ismember(condition,['A':'Z' 'a':'z' '0':'9'])))(i,1:tmpostNum)=stepLengthAsym(1:tmpostNum);
            Data.([condition(ismember(condition,['A':'Z' 'a':'z' '0':'9'])) 'obs'])(i,1:tmpostNum)=SLasymObs(1:tmpostNum);
        else
            Data.(condition(ismember(condition,['A':'Z' 'a':'z' '0':'9'])))(i,1:tmbaseNum)=stepLengthAsym(1:tmbaseNum);
            Data.([condition(ismember(condition,['A':'Z' 'a':'z' '0':'9'])) 'obs'])(i,1:tmbaseNum)=SLasymObs(1:tmbaseNum);
        end
        clearvars -except adaptData Data i cond s adaptNum tmpostNum tmbaseNum        
    end
    i=i+1;
end


