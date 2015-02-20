function results = barGroups(SMatrix,params,groups,findMaxPerturb,plotFlag,indivFlag)

% Set colors
poster_colorsHH;
% Set colors order
GreyOrder=[0 0 0 ;1 1 1;0.5 0.5 0.5;0.2 0.2 0.2;0.9 0.9 0.9;0.1 0.1 0.1;0.8 0.8 0.8;0.3 0.3 0.3;0.7 0.7 0.7];
%ColorOrder=[p_red; p_orange; p_fade_green; p_fade_blue; p_plum; p_green; p_blue; p_fade_red; p_lime; p_yellow; p_gray; p_black;[1 1 1]];
            
 ColorOrder=[p_red; p_orange; p_violet; p_green; p_dark_red; p_yellow; p_dark_green; p_blue; p_dark_blue; p_fade_green; p_fade_blue; p_fade_orange; p_fade_red];
%            %OA       OG         OANC       YA     OASV         OGNC       YASV        YG      YGNC           YASS        YGSS          OGSS          OASS
           
%ColorOrder=[p_red; p_orange; p_green; p_blue; p_dark_blue; p_fade_green; p_fade_blue; p_fade_orange; p_fade_red];
           %OA       OG        YA       YG      YGNC           YASS        YGSS          OGSS          OASS

catchNumPts = 3; % catch
steadyNumPts = 40; %end of adaptation
transientNumPts = 5; % OG and Washout

if nargin<3 || isempty(groups)
    groups=fields(SMatrix);          
end
ngroups=length(groups);

results.ErrorsOut.avg=[];
results.ErrorsOut.se=[];

results.AvgAdapt.avg=[];
results.AvgAdapt.se=[];

results.catch.avg=[];
results.catch.se=[];

results.TMsteady2.avg=[];
results.TMsteady2.se=[];

results.OGafter.avg=[];
results.OGafter.se=[];

results.TMafter.avg=[];
results.TMafter.se=[];

results.Transfer.avg=[];
results.Transfer.se=[];

results.Washout.avg=[];
results.Washout.se=[];

results.Transfer2.avg=[];
results.Transfer2.se=[];

results.Washout2.avg=[];
results.Washout2.se=[];

results.TMbase.avg=[];
results.TMbase.se=[];

results.OGbase.avg=[];
results.OGbase.se=[];

results.TMsteady1.avg=[];
results.TMsteady1.se=[];

for g=1:ngroups
    %get subjects in group
    subjects=SMatrix.(groups{g}).IDs(:,1);
    
    ErrorsOut=[];
    OGbase=[];
    TMbase=[];
    tmsteady1=[];
    tmcatch=[];
    tmsteady2=[];
    avgadapt=[];
    ogafter=[];
    tmafter=[];
    transfer=[];
    washout=[];
    transfer2=[];
    washout2=[];
        
    for s=1:length(subjects)
        %load subject
        load([subjects{s} 'params.mat'])
        
        %normalize contributions based on combined step lengths
        SLf=adaptData.data.getParameter('stepLengthFast');
        SLs=adaptData.data.getParameter('stepLengthSlow');
        Dist=SLf+SLs;
        contLabels={'spatialContribution','stepTimeContribution','velocityContribution','netContribution'};
        [~,dataCols]=isaParameter(adaptData.data,contLabels);
        for c=1:length(contLabels)
            contData=adaptData.data.getParameter(contLabels(c));
            contData=contData./Dist;
            adaptData.data.Data(:,dataCols(c))=contData;
        end
        
        %EDIT: create contribution error values
        vels=adaptData.data.getParameter('stanceSpeedSlow');
        velf=adaptData.data.getParameter('stanceSpeedFast');
        deltaST=adaptData.data.getParameter('stanceTimeDiff');
        velCont=adaptData.data.getParameter('velocityContribution');
        stepCont=adaptData.data.getParameter('stepTimeContribution');
        spatialCont=adaptData.data.getParameter('spatialContribution');
        Tideal=((vels+velf)./2).*deltaST./Dist;
        Sideal=(-velCont)-Tideal;
        [~,dataCols]=isaParameter(adaptData.data,{'Tgoal','Sgoal'});
        adaptData.data.Data(:,dataCols(1))=Tideal-stepCont;
        adaptData.data.Data(:,dataCols(2))=Sideal-spatialCont;
        
        %remove baseline bias
        %adaptData=adaptData.removeBias;
        
        
         if nargin>3 && findMaxPerturb==1
            
            %calculate TM and OG base in same manner as calculating OG post and TM
            %post to ensure that they are different.

            OGbaselineData=adaptData.getParamInCond(params,'OG base');
            [newOGbaselineData,~]=bin_dataV1(OGbaselineData,transientNumPts);
            [~,maxLoc]=max(abs(newOGbaselineData),[],1);
            ind=sub2ind(size(newOGbaselineData),maxLoc,1:length(params));
            OGbase=[OGbase; newOGbaselineData(ind)];

            TMbaselineData=adaptData.getParamInCond(params,'TM base');
            if isempty(TMbaselineData)
                TMbaselineData=adaptData.getParamInCond(params,{'slow base','fast base'});
            end
            [newTMbaselineData,~]=bin_dataV1(TMbaselineData,transientNumPts);
            [~,maxLoc]=max(abs(newTMbaselineData),[],1);
            ind=sub2ind(size(newTMbaselineData),maxLoc,1:length(params));
            TMbase=[TMbase; newTMbaselineData(ind)];

%             %calculate catch as mean value during strides which caused a
%             %maximum deviation from zero in step length asymmetry during 
%             %'catchNumPts' consecutive steps
%             stepAsymData=adaptData.getParamInCond('stepLengthAsym','catch');
%             tmcatchData=adaptData.getParamInCond(params,'catch');
%             if isempty(tmcatchData)
%                 newtmcatchData=NaN(1,length(params));
%                 newStepAsymData=NaN;
%             elseif size(tmcatchData,1)<3
%                 newtmcatchData=nanmean(tmcatchData);
%                 newStepAsymData=nanmean(stepAsymData);
%             else
%                 [newStepAsymData,~]=bin_dataV1(stepAsymData,catchNumPts);
%                 [newtmcatchData,~]=bin_dataV1(tmcatchData,catchNumPts);
%             end        
%             [~,maxLoc]=max(abs(newStepAsymData),[],1);
% %             ind=sub2ind(size(newtmcatchData),maxLoc*ones(1,length(params)),1:length(params));
%             tmcatch=[tmcatch; newtmcatchData(maxLoc,:)];
            
            %calculate catch as mean value during strides which caused a
            %maximum deviation from zero during 
            %'catchNumPts' consecutive steps
            tmcatchData=adaptData.getParamInCond(params,'catch');
            if isempty(tmcatchData)
                newtmcatchData=NaN(1,length(params));
                newStepAsymData=NaN;
            elseif size(tmcatchData,1)<3
                newtmcatchData=nanmean(tmcatchData);
                newStepAsymData=nanmean(stepAsymData);
            else
                [newtmcatchData,~]=bin_dataV1(tmcatchData,catchNumPts);
            end        
            [~,maxLoc]=max(abs(newtmcatchData),[],1);
            ind=sub2ind(size(newtmcatchData),maxLoc,1:length(params));
            tmcatch=[tmcatch; newtmcatchData(ind)];
            
            %calculate OG after as mean values during strides which cause a
            %maximum deviation from zero in step length asymmetry during
            %'transientNumPts' consecutive steps within first 10 strides
            stepAsymData=adaptData.getParamInCond('stepLengthAsym','OG post');
            transferData=adaptData.getParamInCond(params,'OG post');
            [newStepAsymData,~]=bin_dataV1(stepAsymData(1:10,:),transientNumPts);
            [newTransferData,~]=bin_dataV1(transferData(1:10,:),transientNumPts);
            [~,maxLoc]=max(abs(newStepAsymData),[],1);
%             ind=sub2ind(size(newTransferData),maxLoc*ones(1,length(params)),1:length(params));
            ogafter=[ogafter; newTransferData(maxLoc,:)];
        
            %calculate TM after-effects same as OG after-effect
            stepAsymData=adaptData.getParamInCond('stepLengthAsym','TM post');
            tmafterData=adaptData.getParamInCond(params,'TM post');
            [newStepAsymData,~]=bin_dataV1(stepAsymData(1:10,:),transientNumPts);
            [newtmafterData,~]=bin_dataV1(tmafterData(1:10,:),transientNumPts);
            [~,maxLoc]=max(abs(newStepAsymData),[],1);
%             ind=sub2ind(size(newtmafterData),maxLoc*ones(1,length(params)),1:length(params));
            tmafter=[tmafter; newtmafterData(maxLoc,:)];
            
        else
            
            %calculate TM and OG base as mean value? --> should be zero...

            OGbaselineData=adaptData.getParamInCond(params,'OG base');
            [newOGbaselineData,~]=bin_dataV1(OGbaselineData,transientNumPts);
            [~,maxLoc]=max(abs(newOGbaselineData),[],1);
            ind=sub2ind(size(newOGbaselineData),maxLoc,1:length(params));
            OGbase=[OGbase; newOGbaselineData(ind)];

            TMbaselineData=adaptData.getParamInCond(params,'TM base');
            if isempty(TMbaselineData)
                TMbaselineData=adaptData.getParamInCond(params,{'slow base','fast base'});
            end
            [newTMbaselineData,~]=bin_dataV1(TMbaselineData,transientNumPts);
            [~,maxLoc]=max(abs(newTMbaselineData),[],1);
            ind=sub2ind(size(newTMbaselineData),maxLoc,1:length(params));
            TMbase=[TMbase; newTMbaselineData(ind)];
            
            %calculate catch
            tmcatchData=adaptData.getParamInCond(params,'catch');
            if isempty(tmcatchData)
                newtmcatchData=NaN(1,length(params));
            elseif size(tmcatchData,1)<3
                newtmcatchData=nanmean(tmcatchData);
            else
                newtmcatchData=nanmean(tmcatchData(1:catchNumPts,:));
                %newtmcatchData=nanmean(tmcatchData);
            end
            tmcatch=[tmcatch; newtmcatchData];  
            
            %calculate Transfer
            transferData=adaptData.getParamInCond(params,'OG post');
            ogafter=[ogafter; nanmean(transferData(1:transientNumPts,:))];
            
            %calculate TM after-effects
            tmafterData=adaptData.getParamInCond(params,'TM post');
            tmafter=[tmafter; nanmean(transferData(1:transientNumPts,:))];            
        end
        

        
        %calculate TM steady state #1
        adapt1Data=adaptData.getParamInCond(params,{'adaptation','re-adaptation'});
        adapt2Data=adaptData.getParamInCond(params,{'adaptation'});
        velAdaptation=adaptData.getParamInCond('velocityContribution','adaptation');
        tmsteady1=[tmsteady1;nanmean(adapt2Data((end-5)-steadyNumPts+1:(end-5),:))]; 
        
        %avgadapt=[avgadapt;nanmean(-velAdaptation*ones(1,length(params))-adapt1Data)];
        
%         %find maximum adapatation errors
%         [newadapt1Data,~]=bin_dataV1(adapt1Data,300);
%         [~,maxLoc]=max(abs(newadapt1Data),[],1);
%         ind=sub2ind(size(newadapt1Data),maxLoc,1:length(params));
        avgadapt=[avgadapt; nanmean(adapt2Data)];
        
        %Calculate Errors outside of baseline during adaptation
        mu=nanmean(TMbaselineData);
        sigma=nanstd(TMbaselineData);
        upper=mu+2.*sigma;
        lower=mu-2.*sigma;
        for i=1:length(params)
            outside(i)=sum(adapt1Data(:,i)>upper(i) | adapt1Data(:,i)<lower(i));
        end
        ErrorsOut=[ErrorsOut; 100.*(outside./size(adapt1Data,1))];

        %calculate TM steady state #2
        adapt2Data=adaptData.getParamInCond(params,'re-adaptation');
        tmsteady2=[tmsteady2;nanmean(adapt2Data((end-5)-steadyNumPts+1:(end-5),:))];      
        
    end   
    
    %calculate relative after-effects
%     transfer=[transfer; 100*(ogafter./(tmcatch))];
%     transfer=[transfer; 100*(ogafter./(tmcatch(:,3)*ones(1,3)))];
    transfer=[transfer; 100*(ogafter./(tmcatch))];
    washout=[washout; 100-(100*(tmafter./tmcatch))];

    transfer2=[transfer2; 100*(ogafter./tmsteady2)];
    washout2=[washout2; 100-(100*(tmafter./tmsteady2))];
    
    nSubs=length(subjects);
    
    results.ErrorsOut.avg(end+1,:)=nanmean(ErrorsOut,1);
    results.ErrorsOut.se(end+1,:)=nanstd(ErrorsOut,1)./sqrt(nSubs);
       
    results.OGbase.avg(end+1,:)=nanmean(OGbase,1);
    results.OGbase.se(end+1,:)=nanstd(OGbase,1)./sqrt(nSubs);
    
    
    results.TMbase.avg(end+1,:)=nanmean(TMbase,1);
    results.TMbase.se(end+1,:)=nanstd(TMbase,1);
    
    
    results.TMsteady1.avg(end+1,:)=nanmean(tmsteady1,1);
    results.TMsteady1.se(end+1,:)=nanstd(tmsteady1,1)./sqrt(nSubs);
   
    
    results.catch.avg(end+1,:)=nanmean(tmcatch,1);
    results.catch.se(end+1,:)=nanstd(tmcatch,1)./sqrt(nSubs);
    
    
    results.TMsteady2.avg(end+1,:)=nanmean(tmsteady2,1);
    results.TMsteady2.se(end+1,:)=nanstd(tmsteady2,1)./sqrt(nSubs);
    
    
    results.AvgAdapt.avg(end+1,:)=nanmean(avgadapt,1);
    results.AvgAdapt.se(end+1,:)=nanstd(avgadapt,1)./sqrt(nSubs);
    
    
    results.OGafter.avg(end+1,:)=nanmean(ogafter,1);
    results.OGafter.se(end+1,:)=nanstd(ogafter,1)./sqrt(nSubs);
    
    
    results.TMafter.avg(end+1,:)=nanmean(tmafter,1);
    results.TMafter.se(end+1,:)=nanstd(tmafter,1)./sqrt(nSubs);
     
    
    results.Transfer.avg(end+1,:)=nanmean(transfer,1);
    results.Transfer.se(end+1,:)=nanstd(transfer,1)./sqrt(nSubs);
    
    
    results.Washout.avg(end+1,:)=nanmean(washout,1);
    results.Washout.se(end+1,:)=nanstd(washout,1)./sqrt(nSubs);
   
    
    results.Transfer2.avg(end+1,:)=nanmean(transfer2,1);
    results.Transfer2.se(end+1,:)=nanstd(transfer2,1)./sqrt(nSubs);
    
    
    results.Washout2.avg(end+1,:)=nanmean(washout2,1);
    results.Washout2.se(end+1,:)=nanstd(washout2,1)./sqrt(nSubs);
    
    if g==1
        for p=1:length(params)        
            results.ErrorsOut.indiv.(params{p})=[g*ones(nSubs,1) ErrorsOut(:,p)];
            results.OGbase.indiv.(params{p})=[g*ones(nSubs,1) OGbase(:,p)];
            results.TMbase.indiv.(params{p})=[g*ones(nSubs,1) TMbase(:,p)];
            results.TMsteady1.indiv.(params{p})=[g*ones(nSubs,1) tmsteady1(:,p)];
            results.catch.indiv.(params{p})=[g*ones(nSubs,1) tmcatch(:,p)];
            results.TMsteady2.indiv.(params{p})=[g*ones(nSubs,1) tmsteady2(:,p)];
            results.AvgAdapt.indiv.(params{p})=[g*ones(nSubs,1) avgadapt(:,p)];
            results.OGafter.indiv.(params{p})=[g*ones(nSubs,1) ogafter(:,p)];
            results.TMafter.indiv.(params{p})=[g*ones(nSubs,1) tmafter(:,p)];
            results.Transfer.indiv.(params{p})=[g*ones(nSubs,1) transfer(:,p)];
            results.Washout.indiv.(params{p})=[g*ones(nSubs,1) washout(:,p)];
            results.Transfer2.indiv.(params{p})=[g*ones(nSubs,1) transfer2(:,p)];
            results.Washout2.indiv.(params{p})=[g*ones(nSubs,1) washout2(:,p)];
        end
    else        
        for p=1:length(params)        
            results.ErrorsOut.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) ErrorsOut(:,p)];
            results.OGbase.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) OGbase(:,p)];
            results.TMbase.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) TMbase(:,p)];
            results.TMsteady1.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmsteady1(:,p)];
            results.catch.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmcatch(:,p)];
            results.TMsteady2.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmsteady2(:,p)];
            results.AvgAdapt.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) avgadapt(:,p)];
            results.OGafter.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) ogafter(:,p)];
            results.TMafter.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) tmafter(:,p)];
            results.Transfer.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) transfer(:,p)];
            results.Washout.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) washout(:,p)];
            results.Transfer2.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) transfer2(:,p)];
            results.Washout2.indiv.(params{p})(end+1:end+nSubs,1:2)=[g*ones(nSubs,1) washout2(:,p)];
        end
    end
end

%plot stuff
if nargin>4 && plotFlag
    epochs=fields(results);
    %epochs={'TMsteady1','catch','TMsteady2','OGafter','TMafter'};    
    
%     %plot first three epochs
%     numPlots=3*length(params); 
%     ah=optimizedSubPlot(numPlots,length(params),3,'ltr');
%     i=1;
%     for p=1:length(params)
%         limy=[];
%         for t=1:3    
%             axes(ah(i))
%             hold on        
%             for b=1:ngroups
%                 nSubs=length(SMatrix.(groups{b}).IDs(:,1));
%                 if nargin>5 && ~isempty(indivFlag)
%                     bar(b,results.(epochs{t}).avg(b,p),'facecolor',GreyOrder(b,:));
%                     for s=1:nSubs
%                         plot(b,results.(epochs{t}).indiv.(groups{b})(s,p),'*','Color',ColorOrder(s,:))
%                     end
%                 else
%                     bar(b,results.(epochs{t}).avg(b,p),'facecolor',ColorOrder(b,:));
%                 end                                
%             end
%             errorbar(results.(epochs{t}).avg(:,p),results.(epochs{t}).se(:,p),'.','LineWidth',2,'Color','k')
%             set(gca,'Xtick',1:ngroups,'XTickLabel',groups,'fontSize',12)
%             axis tight
%             if t<3
%                 limy=[limy get(gca,'Ylim')];
%             end
%             ylabel(params{p})
%             title(epochs{t})
%             i=i+1;
% 
%         end
%         set(ah(p*3-2:p*3-1),'Ylim',[min(limy) max(limy)])
%     end

    %plot first five epochs
    numPlots=5*length(params); 
    ah=optimizedSubPlot(numPlots,length(params),5,'ltr');
    i=1;
    for p=1:length(params)
        limy=[];
        for t=7:12    
            axes(ah(i))
            hold on        
            for b=1:ngroups
                nSubs=length(SMatrix.(groups{b}).IDs(:,1));
                ind=find(strcmp(fields(SMatrix),groups{b}));
                if nargin>5 && indivFlag
                    bar(b,results.(epochs{t}).avg(b,p),'facecolor',GreyOrder(ind,:));
                    for s=1:nSubs
                        plot(b,results.(epochs{t}).indiv.(groups{b})(s,p),'*','Color',ColorOrder(s,:))
                    end
                else
                    bar(b,results.(epochs{t}).avg(b,p),'facecolor',ColorOrder(ind,:));
                end                                
            end
            errorbar(results.(epochs{t}).avg(:,p),results.(epochs{t}).se(:,p),'.','LineWidth',2,'Color','k')
            set(gca,'Xtick',1:ngroups,'XTickLabel',groups,'fontSize',12)
            axis tight
            limy=[limy get(gca,'Ylim')];
            ylabel(params{p})
            title(epochs{t})
            i=i+1;

        end
        %set(ah(p*5-4:p*5),'Ylim',[min(limy) max(limy)])
        set(gcf,'Renderer','painters');
    end


    %plot last four epochs
    numPlots=4*length(params);
    ah=optimizedSubPlot(numPlots,length(params),4,'ltr');
    i=1;
    for p=1:length(params)
        %limy=[];
        for t=6:9
            axes(ah(i))
            hold on        
            for b=1:ngroups
                nSubs=length(SMatrix.(groups{b}).IDs(:,1));
                ind=find(strcmp(fields(SMatrix),groups{b}));
                if nargin>5 && indivFlag
                    bar(b,results.(epochs{t}).avg(b,p),'facecolor',GreyOrder(ind,:));
                    for s=1:nSubs
                        plot(b,results.(epochs{t}).indiv.(groups{b})(s,p),'*','Color',ColorOrder(s,:))
                    end
                else
                    bar(b,results.(epochs{t}).avg(b,p),'facecolor',ColorOrder(ind,:));
                end 
            end
            errorbar(results.(epochs{t}).avg(:,p),results.(epochs{t}).se(:,p),'.','LineWidth',2,'Color','k')
            set(gca,'Xtick',1:ngroups,'XTickLabel',groups,'fontSize',12)
            axis tight
            %limy=[limy get(gca,'Ylim')];
            ylabel(params{p})
            title(epochs{t})
            i=i+1;
        end
        %set(ah(p*4-3:p*4),'Ylim',[min(limy) max(limy)])
        set(gcf,'Renderer','painters');
    end
end


