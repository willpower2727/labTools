function out = calcExperimentalParams(in)
%in must be an object of the class processedlabData
%
%To add a new parameter, it must be added to the paramLabels
%cell and the label must be the same as the variable name the data is saved
%to. (ex: in paramlabels: 'swingTimeSlow', in code: swingTimeSlow(i)=timeSHS2-timeSTO;)

disp('Running calcExperimentalParams');

paramlabels = {    
'speedDiffSlow',...
'speedDiffFast',};
% % 'COPrangeS',... %Range of COP movement along step direction during a stance phase
% % 'COPrangeF',...
% % 'COPsym',... %Difference in COP ranges normalized by sum
% % 'COPsymM',... %COPsym as defined by Mawase
% % 'rF',... %Stance time during last gait cycle, divided by stride time
% % 'rS',... %Idem 
% % 'cF',... %Average of ankle position at HS2 and previous TO
% % 'cS',... %Idem
% % 'TF',... %Stride time, time between consecutive HSs
% % 'TS',... %Idem
% % 'phiF',... %Time at HS, divided by stride time. Not meaningful by itself
% % 'phiS',... %Idem
% % 'AF',... %Ankle position at HS2 minus position at previous TO
% % 'AS',... %Idem
% % 'rSym',... %rF-rS, 
% % 'cSym',... %cF-cS, center of oscillation difference
% % 'phiSym',... %phiF-phiS, relative heel-strike timing
% % 'ASym',...  %Amplitude difference
% % 'uS','yS','yS_hat','eS','foreaftRatioS','nS','utS','ytS','ytS_hat','etS','ntS',...
% % 'uF','yF','yF_hat','eF','foreaftRatioF','nF','utF','ytF','ytF_hat','etF','ntF'}; %Gelsy's params

%make the time series have a time vector as small as possible so that
% a) it does not take up an unreasonable amount of space
% b) the paramaters can be plotted along with the GRF/kinematic data and
% the events used to create each data point can be distinguished.
sampPeriod=0.2;
f_params=1/sampPeriod;

if in.metaData.refLeg == 'R'
    s = 'R';
    f = 'L';
elseif in.metaData.refLeg == 'L'
    s = 'L';
    f = 'R';
else
    ME=MException('MakeParameters:refLegError','the refLeg property of metaData must be either ''L'' or ''R''.');
    throw(ME);
end

%% Find number of strides
good=in.adaptParams.getDataAsVector({'good'}); %Getting data from 'good' label
ts=~isnan(good);
good=good(ts);
Nstrides=length(good);%Using lenght of the 'good' parameter already calculated in calcParams

%% get events
f_events=in.gaitEvents.sampFreq;
events=in.gaitEvents.getDataAsVector({[s,'HS'],[f,'HS'],[s,'TO'],[f,'TO']});
eventsTime=in.gaitEvents.Time;

%% get kinematics
f_kin=in.markerData.sampFreq;
%get orientation
if isempty(in.markerData.orientation)
    warning('Assuming default orientation of axes for marker data.');
    orientation=orientationInfo([0,0,0],'x','y','z',1,1,1);
else
    orientation=in.markerData.orientation;
end

if ~isempty(in.angleData) %This checks that hip and ankle markers are present
    %get hip position    
    sHip=in.getMarkerData({[s 'HIP' orientation.sideAxis],[s 'HIP' orientation.foreaftAxis],[s 'HIP' orientation.updownAxis]});
    sHip=[orientation.sideSign*sHip(:,1),orientation.foreaftSign*sHip(:,2),orientation.updownSign*sHip(:,3)];
    fHip=in.getMarkerData({[f 'HIP' orientation.sideAxis],[f 'HIP' orientation.foreaftAxis],[f 'HIP' orientation.updownAxis]});
    fHip=[orientation.sideSign*fHip(:,1),orientation.foreaftSign*fHip(:,2),orientation.updownSign*fHip(:,3)];
    %get ankle position
    sAnk=in.getMarkerData({[s 'ANK' orientation.sideAxis],[s 'ANK' orientation.foreaftAxis],[s 'ANK' orientation.updownAxis]});
    sAnk=[orientation.sideSign*sAnk(:,1),orientation.foreaftSign*sAnk(:,2),orientation.updownSign*sAnk(:,3)];
    fAnk=in.getMarkerData({[f 'ANK' orientation.sideAxis],[f 'ANK' orientation.foreaftAxis],[f 'ANK' orientation.updownAxis]});
    fAnk=[orientation.sideSign*fAnk(:,1),orientation.foreaftSign*fAnk(:,2),orientation.updownSign*fAnk(:,3)];
    %get angle data
    angles=in.angleData.getDataAsVector({[s,'Limb'],[f,'Limb']});
    sAngle=angles(:,1);
    fAngle=angles(:,2);
    
    calcSpatial=true;
else
    calcSpatial=false;    
end

%% Initialize params
paramTSlength=Nstrides;
numParams=length(paramlabels);
for i=1:numParams
    eval([paramlabels{i},'=NaN(paramTSlength,1);'])
end

%% Calculate parameters
times=zeros(Nstrides,1);        
for step=1:Nstrides   
    %get indices and times
    [indSHS,indFTO,indFHS,indSTO,indSHS2,indFTO2,indFHS2,indSTO2,timeSHS,timeFTO,timeFHS,timeSTO,timeSHS2,timeFTO2,timeFHS2,timeSTO2] = getIndsForThisStep(events,eventsTime,step);
    times(step)=mean([timeSHS timeFTO timeFHS timeSTO timeSHS2 timeFTO2]);
    t=step;
    if good(step)
        %[COPrangeF(t),COPrangeS(t),COPsym(t),COPsymM(t),handHolding(t)] = computeForceParameters(in.GRFData,s,f,indSHS,indSTO,indFHS,indFTO,indSHS2,indFTO2);
% %         
% %         [rF(t),rS(t),cF(t),cS(t),TF(t),TS(t),phiF(t),phiS(t),AF(t),AS(t),rSym(t),cSym(t),phiSym(t),ASym(t)] = computePablosParameters(in.markerData.split(timeSHS,timeFTO2),s,f,timeSHS,timeSTO,timeFHS,timeFTO,timeSHS2,timeFTO2);
% %         if ~isempty(timeFTO2) && ~isempty(timeFHS2) && ~isempty(timeSTO2) && ~isempty(timeSHS2)
% %             [uS(t),yS(t),foreaftRatioS(t),utS(t),ytS(t),ytS_hat(t),uF(t),yF(t),foreaftRatioF(t),utF(t),ytF(t),ytF_hat(t)] = computeGelsysParameters(in.markerData,s,f,timeSHS,timeFTO,timeFHS,timeSTO,timeSHS2,timeFTO2,timeFHS2,timeSTO2);
% %         end 
        
        if calcSpatial
            CF=f_kin/f_events;
            indSHS=round(indSHS*CF);
            indFTO=round(indFTO*CF);
            indFHS=round(indFHS*CF);
            indSTO=round(indSTO*CF);
            indSHS2=round(indSHS2*CF);
            indFTO2=round(indFTO2*CF);
            
            %Compute mean (across the two markers) hip position (in fore-aft axis)
            meanHipPos=nanmean([sHip(:,2) fHip(:,2)],2);
            meanHipPos2D=[meanHipPos nanmean([sHip(:,3) fHip(:,3)],2)];
            
            %Compute ankle position relative to average hip position
            sAnkPos=sAnk(:,2)-meanHipPos;
            fAnkPos=fAnk(:,2)-meanHipPos;
            
            %compute limb angle relative to average hip position
            sLimbAngle = calcangle([sAnk(:,2) sAnk(:,3)], [meanHipPos2D(:,1) meanHipPos2D(:,2)], [meanHipPos2D(:,1)+100 meanHipPos2D(:,2)])-90;
            fLimbAngle = calcangle([fAnk(:,2) fAnk(:,3)], [meanHipPos2D(:,1) meanHipPos2D(:,2)], [meanHipPos2D(:,1)+100 meanHipPos2D(:,2)])-90;
            
            speedDiffSlow(t)=0;
            for ind=(indSHS+1):indFHS
                L=norm([sHip(ind,2)-sAnk(ind,2) sHip(ind,3)-sAnk(ind,3)]);
                speedDiffSlow(t)=speedDiffSlow(t)+L*(sind(sLimbAngle(ind))-sind(sLimbAngle(ind-1)))-(sAnk(ind,2)-sAnk(ind-1,2));
            end
            
            speedDiffFast(t)=0;
            for ind=(indFHS+1):indSHS2
                L=norm([fHip(ind,2)-fAnk(ind,2) fHip(ind,3)-fAnk(ind,3)]);
                speedDiffFast(t)=speedDiffFast(t)+L*(sind(fLimbAngle(ind))-sind(fLimbAngle(ind-1)))-(fAnk(ind,2)-fAnk(ind-1,2));
            end
            
            
        end
            %Contributions
%           % Compute spatial contribution (1D)
%             spatialFast=fAnkPos(indFHS) - sAnkPos(indSHS);
%             spatialSlow=sAnkPos(indSHS2) - fAnkPos(indFHS);
%             
%             % Compute spatial contribution (2D)
%             sAnkPosHS=norm(sAnkPos2D(indSHS,:)); 
%             fAnkPosHS=norm(fAnkPos2D(indFHS,:));
%             sAnkPosHS2=norm(sAnkPos2D(indSHS2,:));
%             spatialFast2D=fAnkPosHS - sAnkPosHS;
%             spatialSlow2D=sAnkPosHS2 - fAnkPosHS;
% 
%             % Compute temporal contributions (convert time to be consistent with
%             % kinematic sampling frequency)
%             ts=round((timeFHS2-timeSHS2)*f_kin)/f_kin; %This rounding should no longer be required, as we corrected indices for kinematic sampling frequency and computed the corresponding times
%             tf=round((timeSHS2-timeFHS)*f_kin)/f_kin; %This rounding should no longer be required, as we corrected indices for kinematic sampling frequency and computed the corresponding times
%             difft=ts-tf;
% 
%             dispSlow=abs(sAnkPos(indFHS2)-sAnkPos(indSHS2));
%             dispFast=abs(fAnkPos(indSHS2)-fAnkPos(indFHS));
% 
%             velocitySlow=dispSlow/ts; % Velocity of foot relative to hip, should be close to actual belt speed in TM trials
%             velocityFast=dispFast/tf;            
%             avgVel=mean([velocitySlow velocityFast]);           
%                      
%             stepTimeContribution2(t)=avgVel*difft;  

    
    end
end
%Compute correlations for Gelsy's params:
% % [yS_hat,eS,nS,ytS_hat,etS,ntS] = computeGelsysParameterCorrelations(uS,yS,utS,ytS,ytS_hat);
% % [yF_hat,eF,nF,ytF_hat,etF,ntF] = computeGelsysParameterCorrelations(uF,yF,utF,ytF,ytF_hat);

%% Save all the params in the data matrix & generate labTimeSeries
for i=1:length(paramlabels)
    eval(['data(:,i)=',paramlabels{i},';'])
end

%out=labTimeSeries(data,eventsTime(1),sampPeriod,paramlabels);
out=parameterSeries(data,paramlabels,times);

%% (?)
% try
%     if any(bad)
%         slashes=find(in.metaData.rawDataFilename=='\' | in.metaData.rawDataFilename=='/');
%         file=in.metaData.rawDataFilename((slashes(end)+1):end);
%         disp(['Warning: Non consistent event detection in ' num2str(sum(bad)) ' strides of ',file])    
%     end
% catch
%     [file] = getSimpleFileName(in.metaData.rawDataFilename);
%         disp(['Warning: No strides detected in ',file])
% end
