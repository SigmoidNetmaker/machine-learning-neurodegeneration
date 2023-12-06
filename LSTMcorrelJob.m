% LSTMcorrelJob.m
% this script does the correlation comparison between:
% NACCv1(RADCv1); RADCv2(RADCv1);
% NACCv2(NACCv1); and NACCscram(RADCscram)
% all of these vectors must be in the workspace:
% comPotRADCv1; comPotRADCv2; comPotNACCv1; comPotNACCv2;
% comPotRADCscram; comPotNACCscram

% load 'em up!
load('RADCestLSTM80Drugs17MinSeq10Ver1')
load('NACCestLSTM80Drugs17MinSeq10Ver1')
cmbPotRADCv1 = cmbPotRADC;
cmbPotNACCv1 = cmbPotNACC;
load('NACCestLSTM80Drugs17MinSeq10noRADC')
cmbPotNACCnR = cmbPotNACC;
load('RADCestLSTM80Drugs17MinSeq10Ver2')
load('NACCestLSTM80Drugs17MinSeq10Ver2')
cmbPotRADCv2 = cmbPotRADC;
cmbPotNACCv2 = cmbPotNACC;
% load('RADCestLSTM80Drugs17MinSeq10Scram')
% load('NACCestLSTM80Drugs17MinSeq10Scram')
load('RADCestL80D17MS10ScramRePerm')
load('NACCestL80D17MS10ScramRePerm')
cmbPotRADCsc = cmbPotRADC;
cmbPotNACCsc = cmbPotNACC;

% call LSTMcorrelate for NACCv1(RADCv1)
cmbPotRADC = cmbPotRADCv1;
cmbPotNACC = cmbPotNACCnR;
LSTMcorrelate
NACCpredNR = NACCpredic;
CoeNnrRv1  = Coeffish
ProNnrRv1  = Probabil

% call LSTMcorrelate for RADCv2(RADCv1)
cmbPotRADC = cmbPotRADCv1;
cmbPotNACC = cmbPotRADCv2;
LSTMcorrelate
RADCpredV2 = NACCpredic;
CoeRv2Rv1  = Coeffish
ProRv2Rv1  = Probabil

% call LSTMcorrelate for NACCv2(NACCv1)
cmbPotRADC = cmbPotNACCv1;
cmbPotNACC = cmbPotNACCv2;
LSTMcorrelate
NACCpredV2 = NACCpredic;
CoeNv2Nv1  = Coeffish
ProNv2Nv1  = Probabil

% call LSTMcorrelate for NACCsc(RADCsc)
cmbPotRADC = cmbPotRADCsc;
cmbPotNACC = cmbPotNACCsc;
LSTMcorrelate
NACCpredSC = NACCpredic;
CoeNscRsc  = Coeffish
ProNscRsc  = Probabil

% get some nice axis bounds
LowRv1  = min(cmbPotRADCv1) - 0.01;
HighRv1 = max(cmbPotRADCv1) + 0.01;
LowNv1  = min(cmbPotNACCv1) - 0.01;
HighNv1 = max(cmbPotNACCv1) + 0.01;

LowNnR  = min(cmbPotNACCnR) - 0.01;
HighNnR = max(cmbPotNACCnR) + 0.01;

LowRv2  = min(cmbPotRADCv2) - 0.01;
HighRv2 = max(cmbPotRADCv2) + 0.01;
LowNv2  = min(cmbPotNACCv2) - 0.01;
HighNv2 = max(cmbPotNACCv2) + 0.01;

LowRsc  = min(cmbPotRADCsc) - 0.001;
HighRsc = max(cmbPotRADCsc) + 0.001;
LowNsc  = min(cmbPotNACCsc) - 0.001;
HighNsc = max(cmbPotNACCsc) + 0.001;

% plot regressionS 
figure(20)
clf
subplot(2,2,1)
plot(cmbPotRADCv1,cmbPotNACCnR,'.b','markersize',0.5)
hold on
plot(RADCseries,NACCpredNR,'r','linewidth',1)
hold off
axis square
axis([LowRv1,HighRv1,LowNnR,HighNnR])
xlabel('ROSMAP prediction V1','fontsize',11,'fontweight','bold')
ylabel('NACC prediction V1','fontsize',11,'fontweight','bold')
textX = LowRv1 + 0.22;
textY = LowNnR + 0.015;
text(textX,textY+0.015,'r = 0.89','fontsize',11,'fontweight','bold')
text(textX,textY+0.000,'p = 0.00','fontsize',11,'fontweight','bold')
textX = LowRv1 + 0.015;
textY = HighNnR - 0.01;
text(textX,textY,'A','fontsize',14,'fontweight','bold')
set(gca,'fontsize',11,'fontweight','bold')
set(gca,'linewidth',1)

subplot(2,2,2)
plot(cmbPotRADCv1,cmbPotRADCv2,'.b','markersize',0.5)
hold on
plot(RADCseries,RADCpredV2,'r','linewidth',1)
hold off
axis square
axis([LowRv1,HighRv1,LowRv2,HighRv2])
xlabel('ROSMAP prediction V1','fontsize',11,'fontweight','bold')
ylabel('ROSMAP prediction V2','fontsize',11,'fontweight','bold')
textX = LowRv1 + 0.22;
textY = LowRv2 + 0.035;
text(textX,textY+0.035,'r = 0.99','fontsize',11,'fontweight','bold')
text(textX,textY+0.000,'p = 0.00','fontsize',11,'fontweight','bold')
textX = LowRv1 + 0.015;
textY = HighRv2 - 0.02;
text(textX,textY,'B','fontsize',14,'fontweight','bold')
set(gca,'fontsize',11,'fontweight','bold')
set(gca,'linewidth',1)

subplot(2,2,3)
plot(cmbPotNACCv1,cmbPotNACCv2,'.b','markersize',0.5)
hold on
plot(RADCseries,NACCpredV2,'r','linewidth',1)
hold off
axis square
axis([LowNv1,HighNv1,LowNv2,HighNv2])
xlabel('NACC prediction V1','fontsize',11,'fontweight','bold')
ylabel('NACC prediction V2','fontsize',11,'fontweight','bold')
textX = LowNv1 + 0.095;
textY = LowNv2 + 0.015;
text(textX,textY+0.015,'r = 0.99','fontsize',11,'fontweight','bold')
text(textX,textY+0.000,'p = 0.00','fontsize',11,'fontweight','bold')
textX = LowNv1 + 0.006;
textY = HighNv2 - 0.011;
text(textX,textY,'C','fontsize',14,'fontweight','bold')
set(gca,'fontsize',11,'fontweight','bold')
set(gca,'linewidth',1)

subplot(2,2,4)
plot(cmbPotRADCsc,cmbPotNACCsc,'.b','markersize',0.5)
hold on
plot(RADCseries,NACCpredSC,'r','linewidth',1)
hold off
axis square
axis([LowRv1,HighRv1,LowNnR,HighNnR])
xlabel('ROSMAP scrambled','fontsize',11,'fontweight','bold')
ylabel('NACC scrambled','fontsize',11,'fontweight','bold')
textX = LowRv1 + 0.22;
textY = LowNnR + 0.015;
text(textX,textY+0.015,'r = 0.88','fontsize',11,'fontweight','bold')
text(textX,textY+0.000,'p = 0.00','fontsize',11,'fontweight','bold')
textX = LowRv1 + 0.015;
textY = HighNnR - 0.01;
text(textX,textY,'D','fontsize',14,'fontweight','bold')
set(gca,'fontsize',11,'fontweight','bold')
set(gca,'linewidth',1)

% just plot out the scrambled version
figure(21)
plot(cmbPotRADCsc,cmbPotNACCsc,'.b','markersize',0.5)
hold on
plot(RADCseries,NACCpredSC,'r','linewidth',1)
hold off
axis square
axis([LowRsc,HighRsc,LowNsc,HighNsc])
xlabel('ROSMAP scrambled','fontsize',11,'fontweight','bold')
ylabel('NACC scrambled','fontsize',11,'fontweight','bold')
textX = LowRsc + 0.06;
textY = LowNsc + 0.005;
text(textX,textY+0.002,'r = 0.88','fontsize',11,'fontweight','bold')
text(textX,textY+0.000,'p = 0.00','fontsize',11,'fontweight','bold')
set(gca,'fontsize',11,'fontweight','bold')
set(gca,'linewidth',1)


