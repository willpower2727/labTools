function barplotGoodStrides
load('Syncronization.mat')

BLeftGoodSteps=0;
for i=1:1:length(GoodL)   
if GoodL(i,1)==1
BLeftGoodSteps=BLeftGoodSteps+1;
else
BLeftGoodSteps=BLeftGoodSteps;  
end 
end

BRigthGoodSteps=0;
for i=1:1:length(GoodR)   
if GoodR(i,1)==1
BRigthGoodSteps=BRigthGoodSteps+1;
else
BRigthGoodSteps=BRigthGoodSteps;
end 
end


BLeft=GoodL(:,1);
BLeft(find(isnan(BLeft)))=[];
BlegthLeft=length(BLeft);

BRigth=GoodR(:,1);
BRigth(find(isnan(BRigth)))=[];
BlegthRigth=length(BRigth);

L(1,1)=BLeftGoodSteps/BlegthLeft;
R(1,1)=BRigthGoodSteps/BlegthRigth;

% ALeftGoodSteps=0;
% ARigthGoodSteps=0;
% for i=1:1:length(AdaptationL)   
% if AdaptationL(i,2)==1
% ALeftGoodSteps=ALeftGoodSteps+1;
% else
% ALeftGoodSteps=ALeftGoodSteps;
% end
% end
% for n=1:1:length(AdaptationR)
% if AdaptationR(n,2)==1
%  ARigthGoodSteps=ARigthGoodSteps+1;   
% else
%  ARigthGoodSteps=ARigthGoodSteps;   
% end
% end
% 
% ALeft=AdaptationL(:,2);
% ALeft(find(isnan(ALeft)))=[];
% AlegthLeft=length(ALeft);
% 
% ARigth=AdaptationR(:,2);
% ARigth(find(isnan(ARigth)))=[];
% AlegthRigth=length(ARigth);
% 
% L(2,1)=ALeftGoodSteps/AlegthLeft;
% R(2,1)=ARigthGoodSteps/AlegthRigth;
% 
% SLeftGoodSteps=0;
% SRigthGoodSteps=0;
% for i=1:1:length(SplitL)   
% if SplitL(i,2)==1
% SLeftGoodSteps=SLeftGoodSteps+1;
% else
% SLeftGoodSteps=SLeftGoodSteps;
% end
% end
% 
% for n=1:1:length(SplitR)
% if SplitR(n,2)==1
%     SRigthGoodSteps=SRigthGoodSteps+1;   
% else
%     SRigthGoodSteps=SRigthGoodSteps;     
% end
% end
% 
% SLeft=SplitL(:,2);
% SLeft(find(isnan(SLeft)))=[];
% SlegthLeft=length(SLeft);
% 
% SRigth=SplitR(:,2);
% SRigth(find(isnan(SRigth)))=[];
% SlegthRigth=length(SRigth);
% 
% L(3,1)=SLeftGoodSteps/SlegthLeft;
% R(3,1)=SRigthGoodSteps/SlegthRigth;
% 
% RLeftGoodSteps=0;
% RRigthGoodSteps=0;
% for i=1:1:length(PostCatch_GoodL)   
% if PostCatch_GoodL(i,1)==1
%  RLeftGoodSteps=RLeftGoodSteps+1;
% else
%    RLeftGoodSteps=RLeftGoodSteps;
% end 
% end
% for i=1:1:length(PostCatch_GoodR)   
% if PostCatch_GoodR(i,1)==1
%    RRigthGoodSteps=RRigthGoodSteps+1;
% else
%    RRigthGoodSteps=RRigthGoodSteps;  
% end
% end
% 
% RLeft=PostCatch_GoodL(:,1);
% RLeft(find(isnan(RLeft)))=[];
% RlegthLeft=length(RLeft);
% 
% RRigth=PostCatch_GoodR(:,1);
% RRigth(find(isnan(RRigth)))=[];
% RlegthRigth=length(RRigth);
% 
% L(2,1)=RLeftGoodSteps/RlegthLeft;
% R(2,1)=RRigthGoodSteps/RlegthRigth;

figure()

for i=1:1:1
hold on
bar((1:1)+(.5+.5.*i),R(i,1),0.2,'FaceColor',[.8,.8,.8])
bar((1:1)+(.7+.5*i),L(i,1),0.2,'FaceColor',[.0,.36,.6])
end
condition={'Gradual Adaptation','Re-adaptation'};
xTickPos=2.1:.5:2*length(condition);
set(gca,'XTick',xTickPos,'XTickLabel',condition)
legend( 'Fast Leg','Slow Leg')
title(['Good Steps' '(',Subject ')'])
end