% ADcomorbidANOVA.m
% this script performs ANOVA on the AD datasets;
% it works with either RADC or NACC;
% see *** statements specific for either;
% the comorbidities are the levels and the combined
% cognitive score as the dependent variable
% it works on In and desOut for RADC or NACC,
% so RADCmakeTruthTable or NACCmakeTruth Table
% must be run first

% compute the combined cognitive score
% from noramlized data in desOut
% (note: desOut has NaNs; compute around them)
numEnt = size(desOut,1);
ccsVec = zeros(numEnt,1);
for i = 1:numEnt
    cogTemp = desOut(i,:);
    ccsVec(i) = mean(cogTemp(~isnan(cogTemp)));
end

% compute number of possible comorbidity combinations
% (note: RADC has 9 comorbs; the closest 9 are selected from NACC)
numPosCombos = 2^9;

% get all comorbidities from In
% store in comorbidity matrix cm
% *** for RADC
% cm = In(:,2:10) == 1;
% *** for NACC
% select the 9 corresponding cormorb columns
NACCcom = [62,79,61,56,65,48,49,43,51];
cm = In(:,NACCcom) == 1;

% find all comorbidity combinations
comCombos = findgroups(cm(:,1),cm(:,2),cm(:,3),cm(:,4),cm(:,5),...
                       cm(:,6),cm(:,7),cm(:,8),cm(:,9));

% sort the unique comorbidity combinaitons, count them,
% and acertain that combinaiton 1 is no comorbidity
[unqComComSort,indxSort,indxRev] = unique(comCombos,'rows');
numComCombos = size(unqComComSort,1);
ComComboOne = cm(indxSort(1),:);

% perform ANOVA for all comorbidity combinations
[pComCombos,tbComCombos,statsComCombos] = ...
    anovan(ccsVec,comCombos);

% compare all combination means using bonferroni correction
figure(10)
multComCombos = multcompare(statsComCombos,'CType','bonferroni');
title([])
yticks([])
xlabel('mean combined cognitive score')
ylabel('comobidity combination')
set(gca,'fontsize',11,'fontweight','bold')

% the rest is not too useful because the graph is too dense
return

% get all the single comorbidies 
com1 = cm(:,1);
com2 = cm(:,2);
com3 = cm(:,3);
com4 = cm(:,4);
com5 = cm(:,5);
com6 = cm(:,6);
com7 = cm(:,7);
com8 = cm(:,8);
com9 = cm(:,9);

% perform ANOVA for comorbidities considered each
[pComEach,tbComEach,statsComEach] = ...
    anovan(ccsVec,{com1,com2,com3,com4,com5,com6,com7,com8,com9},...
    'varnames',{'com1','com2','com3','com4','com5','com6',...
    'com7','com8','com9'});

% compare all combination means using bonferroni correction
figure(11)
clf
multComEach = multcompare(statsComEach,'CType','bonferroni',...
    'dimension',[1,2,3,4,5,6,7,8,9]);


                   


