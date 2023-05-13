% NACCmakeTruthTable.m
% this script makes the NACC truth table from the NACC dataset table; 
% NACCreadDataset must be run first: naccTable must be in workspace

% restore NACC tablet raw as a debug
naccTable = naccTableRaw;

% find number of rows and colums in naccTable
[naccRows, naccCols] = size(naccTable);

% modify NACC dataset table (naccTable) to make all entries numbers,
% and convert all but ID numbers to numbers between 0 and 1

% ID numbers

% convert NACC ID codes to natural numbers
% extract variable
naccID = naccTable.NACCID;
% take number part of NACCID
naccID = erase(naccID,'NACC');
% convert naccID cell array to character array
naccID = char(naccID);
% convert number part of NACCID to number
IDNUM = str2num(naccID);
% add ID variable to naccTable
naccTable = addvars(naccTable,IDNUM,'After','NACCID');

% **** well, computing InNaNpercent will be more messy for NACC ****
% **** outright missing is -4
% **** other stuff like refused to answer is some other code
% **** will have to deal with it later
% compute percent -4s in input rows, which are in temp matrix TM
TM = table2array(naccTable(:,2:102));
InNaNpercent = ...
    sum(sum(TM == -4)) / numel(TM) * 100;

% age variables

% compute birthyear to one month level of precision
% extract variables
visitmo = naccTable.VISITMO;
visityr = naccTable.VISITYR;
birthmo = naccTable.BIRTHMO;
birthyr = naccTable.BIRTHYR;
% compute actual age
AGE = ((visityr - birthyr)*12 + (visitmo - birthmo)) / 12;
% scale AGE to [0,1]
AGE = (AGE - min(AGE)) / max(AGE - min(AGE)); % scale [0,1]
% add age variable to naccTable
naccTable = addvars(naccTable,AGE,'Before','NACCAGE');

% remove uneeded NACC ID and NACC dates/years columns
naccTable = removevars(naccTable,{'NACCID','NACCAGE','VISITMO',...
    'VISITYR','BIRTHMO','BIRTHYR','NACCYOD'});

% demographics

% condition and scale each column of naccTable
% (unknown values are set to average value, then all are scaled)
naccTable.SEX = naccTable.SEX - 1; % now 0 is male (so 1 is female)

temp = naccTable.HISPANIC; % set temp vector, 0 is not hisp, 1 is hisp
naccTable.HISPANIC(temp==9) = mean(temp(temp~=9)); % unknowns to avg

temp = naccTable.RACE; % set temp vector
% by frequency: white > black > asian > native > pacific
% in raw: 1 is white, 2 is black, 3 is native, 4 is pacific, 5 is asian
% reset race so now 3 is asian, 4 is native, and 5 is pacific
% in raw: 50 is other and 99 is unknown
temp(temp==3) = 6; % change all natives to 6's (temporary)
temp(temp==5) = 3; % change all asians to 3's
temp(temp==4) = 5; % change all pacifics to 5's
temp(temp==6) = 4; % change all natives to 4's
temp(temp==99) = 50; % change all unknonws to other
temp(temp==50) = mean(temp(temp~=50)); % replace other/unknown with average
percentRaceAverage = sum(rem(temp,1)~=0) / naccRows * 100; % % replaced
temp = (temp - 1) / 4; % scale race values to range [0,1]
naccTable.RACE = temp; % switch conditioned race values for raw

temp = naccTable.EDUC; % set temp vector
temp(temp==99) = mean(temp~=99); % unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale to [0,1]
naccTable.EDUC = temp; % switch conditioned for raw

% physical variables

temp = naccTable.HEIGHT; % set temp vector
temp(temp==-4) = 88.8; % set missing to unknown
temp(temp==88.8) = mean(temp(temp~=88.8)); % unknown to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.HEIGHT = temp; % switch conditioned for raw

temp = naccTable.WEIGHT; % set temp vector
temp(temp==-4) = 888; % set missing to unknown
temp(temp==888) = mean(temp(temp~=888)); % unknown to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.WEIGHT = temp; % switch conditioned for raw

temp = naccTable.NACCBMI; % set temp vector
temp(temp==-4) = 888.8; % set missing to unknown
temp(temp==888.8) = mean(temp(temp~=888.8)); % unknown to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NACCBMI = temp; % switch conditioned for raw

temp = naccTable.BPSYS; % set temp vector
temp(temp==-4) = 888; % set missing to unknown
temp(temp==888) = mean(temp(temp~=888)); % unknown to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.BPSYS = temp; % switch conditioned for raw

temp = naccTable.BPDIAS; % set temp vector
temp(temp==-4) = 888; % set missing to unknown
temp(temp==888) = mean(temp(temp~=888)); % unknown to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.BPDIAS = temp; % switch conditioned for raw

temp = naccTable.HRATE; % set temp vector
temp(temp==-4) = 888; % set missing to unknown
temp(temp==888) = mean(temp(temp~=888)); % unknown to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.HRATE = temp; % switch conditioned for raw

% tobacco, alcohol, and drugs

temp = naccTable.TOBAC30; % set temp vector, 0 is no, 1 is yes
temp(temp==-4) = 9; % set missing to unknown
naccTable.TOBAC30(temp==9) = mean(temp(temp~=9)); % unknowns to avg

temp = naccTable.TOBAC100; % set temp vector, 0 is no, 1 is yes
temp(temp==-4) = 9; % set missing to unknown
naccTable.TOBAC100(temp==9) = mean(temp(temp~=9)); % unknowns to avg

temp = naccTable.SMOKYRS; % set temp vector
temp(temp==88) = 0; % set not applicable (ie they don't smoke) to 0 years
temp(temp==-4) = 99; % set missing to unknown
temp(temp==99) = mean(temp(temp~=99)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.SMOKYRS = temp; % switch conditioned for raw

temp = naccTable.PACKSPER; % set temp vector
temp(temp==8) = 0; % set not applicable (ie they don't smoke) to 0 
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.PACKSPER = temp; % switch conditioned for raw

temp = naccTable.QUITSMOK; % set temp vector
temp(temp==888) = 0; % set not applicable (ie they don't smoke) to 0 years
temp(temp==-4) = 999; % set missing to unknown
temp(temp==999) = mean(temp(temp~=999)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.QUITSMOK = temp; % switch conditioned for raw

temp = naccTable.ALCOCCAS; % set temp vector, 0 is no, 1 is yes
temp(temp==-4) = 9; % set missing to unknown
naccTable.ALCOCCAS(temp==9) = mean(temp(temp~=9)); % unknowns to avg

temp = naccTable.ALCFREQ; % set temp vector
temp(temp==8) = 0; % set not applicable (ie they don't drink) to 0 
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.ALCFREQ = temp; % switch conditioned for raw

temp = naccTable.ALCOHOL; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.ALCOHOL = temp; % switch conditioned for raw

temp = naccTable.ABUSOTHR; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.ABUSOTHR = temp; % switch conditioned for raw

% medications

temp = naccTable.ANYMEDS; % set temp vector, 0 is no, 1 is yes
naccTable.ANYMEDS(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCAMD; % set temp vector
temp(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NACCAMD = temp; % switch conditioned for raw

temp = naccTable.NACCAHTN; % set temp vector, 0 is no, 1 is yes
naccTable.NACCAHTN(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCHTNC; % set temp vector, 0 is no, 1 is yes
naccTable.NACCHTNC(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCACEI; % set temp vector, 0 is no, 1 is yes
naccTable.NACCACEI(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCAAAS; % set temp vector, 0 is no, 1 is yes
naccTable.NACCAAAS(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCBETA; % set temp vector, 0 is no, 1 is yes
naccTable.NACCBETA(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCCCBS; % set temp vector, 0 is no, 1 is yes
naccTable.NACCCCBS(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCDIUR; % set temp vector, 0 is no, 1 is yes
naccTable.NACCDIUR(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCVASD; % set temp vector, 0 is no, 1 is yes
naccTable.NACCVASD(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCANGI; % set temp vector, 0 is no, 1 is yes
naccTable.NACCANGI(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCLIPL; % set temp vector, 0 is no, 1 is yes
naccTable.NACCLIPL(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCNSD; % set temp vector, 0 is no, 1 is yes
naccTable.NACCNSD(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCAC; % set temp vector, 0 is no, 1 is yes
naccTable.NACCAC(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCADEP; % set temp vector, 0 is no, 1 is yes
naccTable.NACCADEP(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCAPSY; % set temp vector, 0 is no, 1 is yes
naccTable.NACCAPSY(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCAANX; % set temp vector, 0 is no, 1 is yes
naccTable.NACCAANX(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCADMD; % set temp vector, 0 is no, 1 is yes
naccTable.NACCADMD(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCPDMD; % set temp vector, 0 is no, 1 is yes
naccTable.NACCPDMD(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCEMD; % set temp vector, 0 is no, 1 is yes
naccTable.NACCEMD(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCEPMD; % set temp vector, 0 is no, 1 is yes
naccTable.NACCEPMD(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

temp = naccTable.NACCDBMD; % set temp vector, 0 is no, 1 is yes
naccTable.NACCDBMD(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg

% comorbidities

temp = naccTable.CVHATT; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CVHATT = temp; % switch conditioned for raw

temp = naccTable.CVAFIB; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CVAFIB = temp; % switch conditioned for raw

temp = naccTable.CVANGIO; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CVANGIO = temp; % switch conditioned for raw

temp = naccTable.CVBYPASS; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CVBYPASS = temp; % switch conditioned for raw

temp = naccTable.CVPACDEF; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CVPACDEF = temp; % switch conditioned for raw

temp = naccTable.CVCHF; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CVCHF = temp; % switch conditioned for raw

temp = naccTable.CVANGINA; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CVANGINA = temp; % switch conditioned for raw

temp = naccTable.CVHVALVE; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CVHVALVE = temp; % switch conditioned for raw

temp = naccTable.CBSTROKE; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CBSTROKE = temp; % switch conditioned for raw

temp = naccTable.CBTIA; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CBTIA = temp; % switch conditioned for raw

temp = naccTable.PD; % set temp vector, 0 is no, 1 is yes
temp(temp==-4) = 9; % set missing to unknown
naccTable.PD(temp==9) = mean(temp(temp~=9)); % unknowns to avg

temp = naccTable.PDOTHR; % set temp vector, 0 is no, 1 is yes
temp(temp==-4) = 9; % set missing to unknown
naccTable.PDOTHR(temp==9) = mean(temp(temp~=9)); % unknowns to avg

temp = naccTable.SEIZURES; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.SEIZURES = temp; % switch conditioned for raw

temp = naccTable.TBI; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.TBI = temp; % switch conditioned for raw

temp = naccTable.TBIBRIEF; % set temp vector
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % unknown to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.TBIBRIEF = temp; % switch conditioned for raw

temp = naccTable.TBIEXTEN; % set temp vector
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % unknown to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.TBIEXTEN = temp; % switch conditioned for raw

temp = naccTable.TRAUMEXT; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.TRAUMEXT = temp; % switch conditioned for raw

temp = naccTable.TBIWOLOS; % set temp vector
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % unknown to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.TBIWOLOS = temp; % switch conditioned for raw

temp = naccTable.DIABETES; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.DIABETES = temp; % switch conditioned for raw

temp = naccTable.HYPERTEN; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.HYPERTEN = temp; % switch conditioned for raw

temp = naccTable.HYPERCHO; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.HYPERCHO = temp; % switch conditioned for raw

temp = naccTable.B12DEF; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.B12DEF = temp; % switch conditioned for raw

temp = naccTable.THYROID; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.THYROID = temp; % switch conditioned for raw

temp = naccTable.ARTHRIT; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.ARTHRIT = temp; % switch conditioned for raw

temp = naccTable.APNEA; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.APNEA = temp; % switch conditioned for raw

temp = naccTable.RBD; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.RBD = temp; % switch conditioned for raw

temp = naccTable.INSOMN; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.INSOMN = temp; % switch conditioned for raw

temp = naccTable.PTSD; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.PTSD = temp; % switch conditioned for raw

temp = naccTable.BIPOLAR; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.BIPOLAR = temp; % switch conditioned for raw

temp = naccTable.SCHIZ; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.SCHIZ = temp; % switch conditioned for raw

temp = naccTable.DEP2YRS; % set temp vector, 0 is no, 1 is yes
temp(temp==-4) = 9; % set missing to unknown
naccTable.DEP2YRS(temp==9) = mean(temp(temp~=9)); % unknowns to avg

temp = naccTable.DEPOTHR; % set temp vector, 0 is no, 1 is yes
temp(temp==-4) = 9; % set missing to unknown
naccTable.DEPOTHR(temp==9) = mean(temp(temp~=9)); % unknowns to avg

temp = naccTable.ANXIETY; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.ANXIETY = temp; % switch conditioned for raw

temp = naccTable.OCD; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.OCD = temp; % switch conditioned for raw

temp = naccTable.NPSYDEV; % set temp vector
temp(temp==1) = 6; % change all recent to 6's
temp(temp==2) = 1; % change all remotes to 1's
temp(temp==6) = 2; % change all recents to 2's
temp(temp==-4) = 9; % set missing to unknown
temp(temp==9) = mean(temp(temp~=9)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NPSYDEV = temp; % switch conditioned for raw

temp = naccTable.HIV; % set temp vector, 0 is no, 1 is yes
temp(temp==-4) = mean(temp(temp~=-4)); % unknowns to avg
naccTable.HIV = temp; % switch conditioned for raw

temp = naccTable.CANCER; % set temp vector
temp(temp==-4) = 8; % set missing to unknown
temp(temp==8) = mean(temp(temp~=8)); % unknown to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CANCER = temp; % switch conditioned for raw

% dementia diagnoses

% naccTable.DEMENTED is only either 0 for no, 1 for yes!

temp = naccTable.AMNDEM; % set temp vector
temp(temp==1) = 2; % change all AMDS to 2's
temp(temp==0) = 1; % change all nonAMDS to 1's
temp(temp==8) = 0; % change all non-demented to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.AMNDEM = temp; % switch conditioned for raw

temp = naccTable.NACCBVFT; % set temp vector
temp(temp==1) = 2; % change all BVFT to 2's
temp(temp==0) = 1; % change all nonBVFT to 1's
temp(temp==8) = 0; % change all non-demented to 0's
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NACCBVFT = temp; % switch conditioned for raw

temp = naccTable.NACCLBDS; % set temp vector
temp(temp==1) = 2; % change all BVFT to 2's
temp(temp==0) = 1; % change all nonBVFT to 1's
temp(temp==8) = 0; % change all non-demented to 0's
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NACCLBDS = temp; % switch conditioned for raw

temp = naccTable.NAMNDEM; % set temp vector
temp(temp==1) = 2; % change all AMDS to 2's
temp(temp==0) = 1; % change all nonAMDS to 1's
temp(temp==8) = 0; % change all non-demented to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NAMNDEM = temp; % switch conditioned for raw

temp = naccTable.NACCTMCI; % set temp vector
temp(temp==1) = 6; % change all am single to 6's
temp(temp==2) = 7; % change all am multi to 7's
temp(temp==3) = 1; % change all non-am single to 1's
temp(temp==4) = 2; % change all non-am multi to 2's
temp(temp==6) = 3; % change all am single to 3's
temp(temp==7) = 4; % change all am multi to 4's
temp(temp==8) = 0; % change all nonMCI to 0's
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NACCTMCI = temp; % switch conditioned for raw

% naccTable.IMPNOMCI is only either 0 for no, 1 for yes!

temp = naccTable.NACCALZD; % set temp vector
temp(temp==1) = 2; % change all impaired AD to 2's
temp(temp==0) = 1; % change all impaired no AD to 1's
temp(temp==8) = 0; % change not impaired to 0's
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NACCALZD = temp; % switch conditioned for raw

temp = naccTable.PROBAD; % set temp vector
temp(temp==1) = 2; % change all impaired probAD to 2's
temp(temp==0) = 1; % change all impaired no probAD to 1's
temp(temp==8) = 0; % change not impaired to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.PROBAD = temp; % switch conditioned for raw

temp = naccTable.PROBADIF; % set temp vector
temp(temp==1) = 4; % change all primary to 4's
temp(temp==7) = 1; % change all impaired not AD to 1's
temp(temp==2) = 6; % change all contrib to 6's
temp(temp==3) = 2; % change all non-contrib to 2's
temp(temp==6) = 3; % change all contrib to 3's
temp(temp==8) = 0; % change all normal to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.PROBADIF = temp; % switch conditioned for raw

temp = naccTable.POSSAD; % set temp vector
temp(temp==1) = 2; % change all possible AD to 2's
temp(temp==0) = 1; % change all no possible AD to 1's
temp(temp==8) = 0; % change not impaired to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.POSSAD = temp; % switch conditioned for raw

temp = naccTable.POSSADIF; % set temp vector
temp(temp==1) = 4; % change all primary to 4's
temp(temp==7) = 1; % change all impaired not AD to 1's
temp(temp==2) = 6; % change all contrib to 6's
temp(temp==3) = 2; % change all non-contrib to 2's
temp(temp==6) = 3; % change all contrib to 3's
temp(temp==8) = 0; % change all normal to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.POSSADIF = temp; % switch conditioned for raw

temp = naccTable.NACCLBDE; % set temp vector
temp(temp==1) = 2; % change all Lewy to 2's
temp(temp==0) = 1; % change all not Lewy to 1's
temp(temp==8) = 0; % change not impaired to 0's
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NACCLBDE = temp; % switch conditioned for raw

temp = naccTable.NACCLBDP; % set temp vector
temp(temp==1) = 4; % change all primary to 4's
temp(temp==7) = 1; % change all impaired not AD to 1's
temp(temp==2) = 6; % change all contrib to 6's
temp(temp==3) = 2; % change all non-contrib to 2's
temp(temp==6) = 3; % change all contrib to 3's
temp(temp==8) = 0; % change all normal to 0's
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NACCLBDP = temp; % switch conditioned for raw

temp = naccTable.FTD; % set temp vector
temp(temp==1) = 2; % change all FTD to 2's
temp(temp==0) = 1; % change all no FTD to 1's
temp(temp==8) = 0; % change not impaired to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.FTD = temp; % switch conditioned for raw

temp = naccTable.FTDIF; % set temp vector
temp(temp==1) = 3; % change all primary to 3's
temp(temp==7) = 1; % change all impaired not FTD to 1's
% note: the contrib just stay as 2's
temp(temp==8) = 0; % change all normal to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.FTDIF = temp; % switch conditioned for raw

temp = naccTable.VASC; % set temp vector
temp(temp==1) = 2; % change all VASC to 2's
temp(temp==0) = 1; % change all no VASC to 1's
temp(temp==8) = 0; % change not impaired to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.VASC = temp; % switch conditioned for raw

temp = naccTable.VASCIF; % set temp vector
temp(temp==1) = 3; % change all primary to 3's
temp(temp==7) = 1; % change all impaired not FTD to 1's
% note: the contrib just stay as 2's
temp(temp==8) = 0; % change all normal to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.VASCIF = temp; % switch conditioned for raw

temp = naccTable.VASCPS; % set temp vector
temp(temp==1) = 2; % change all preVASC to 2's
temp(temp==0) = 1; % change all no preVASC to 1's
temp(temp==8) = 0; % change not impaired to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.VASCPS = temp; % switch conditioned for raw

temp = naccTable.HIVIF; % set temp vector
temp(temp==1) = 4; % change all primary to 4's
temp(temp==7) = 1; % change all impaired not AD to 1's
temp(temp==2) = 6; % change all contrib to 6's
temp(temp==3) = 2; % change all non-contrib to 2's
temp(temp==6) = 3; % change all contrib to 3's
temp(temp==8) = 0; % change all normal to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.HIVIF = temp; % switch conditioned for raw

% naccTable.MEDS is only either 0 for no, 1 for yes!

temp = naccTable.MEDSIF; % set temp vector
temp(temp==1) = 4; % change all primary to 4's
temp(temp==7) = 1; % change all impaired not AD to 1's
temp(temp==2) = 6; % change all contrib to 6's
temp(temp==3) = 2; % change all non-contrib to 2's
temp(temp==6) = 3; % change all contrib to 3's
temp(temp==8) = 0; % change all normal to 0's
temp(temp==-4) = mean(temp(temp~=-4)); % set unknowns to avg
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MEDSIF = temp; % switch conditioned for raw

% cognitive scores

temp = naccTable.NACCMMSE; % set temp vector
temp(temp==88) = NaN; % set unknown problem to NaN
temp(temp==95) = NaN; % set physical problem to NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.NACCMMSE = temp; % switch conditioned for raw

temp = naccTable.LOGIMEM; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.LOGIMEM = temp; % switch conditioned for raw

temp = naccTable.MEMUNITS; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MEMUNITS = temp; % switch conditioned for raw

temp = naccTable.UDSBENTC; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.UDSBENTC = temp; % switch conditioned for raw

temp = naccTable.UDSBENTD; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.UDSBENTD = temp; % switch conditioned for raw

temp = naccTable.UDSBENRS; % set temp vector, 0 is no, 1 is yes
temp(temp==9) = NaN; % set missing to NaN
temp(temp==-4) = NaN; % set missing to NaN
naccTable.UDSBENRS = temp; % switch conditioned for raw

temp = naccTable.DIGIF; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.DIGIF = temp; % switch conditioned for raw

temp = naccTable.DIGIFLEN; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.DIGIFLEN = temp; % switch conditioned for raw

temp = naccTable.DIGIB; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.DIGIB = temp; % switch conditioned for raw

temp = naccTable.DIGIBLEN; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.DIGIBLEN = temp; % switch conditioned for raw

temp = naccTable.ANIMALS; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.ANIMALS = temp; % switch conditioned for raw

temp = naccTable.VEG; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.VEG = temp; % switch conditioned for raw

temp = naccTable.TRAILA; % set temp vector
temp(temp==995) = NaN; % set  problem NaN
temp(temp==996) = NaN; % set behavioral problem to NaN
temp(temp==997) = NaN; % set other problem to NaN
temp(temp==998) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.TRAILA = temp; % switch conditioned for raw

temp = naccTable.TRAILARR; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to problem
temp(temp==97) = NaN; % set other problem to problem
temp(temp==98) = NaN; % set verbal refusal to problem
temp(temp==-4) = NaN; % set missing data to problem
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.TRAILARR = temp; % switch conditioned for raw

temp = naccTable.TRAILALI; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.TRAILALI = temp; % switch conditioned for raw

temp = naccTable.TRAILB; % set temp vector
temp(temp==995) = NaN; % set  problem NaN
temp(temp==996) = NaN; % set behavioral problem to NaN
temp(temp==997) = NaN; % set other problem to NaN
temp(temp==998) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.TRAILB = temp; % switch conditioned for raw

temp = naccTable.TRAILBRR; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.TRAILBRR = temp; % switch conditioned for raw

temp = naccTable.TRAILBLI; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.TRAILBLI = temp; % switch conditioned for raw

temp = naccTable.WAIS; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.WAIS = temp; % switch conditioned for raw

temp = naccTable.BOSTON; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.BOSTON = temp; % switch conditioned for raw

temp = naccTable.UDSVERFC; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.UDSVERFC = temp; % switch conditioned for raw

temp = naccTable.UDSVERFN; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.UDSVERFN = temp; % switch conditioned for raw

temp = naccTable.UDSVERNF; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.UDSVERNF = temp; % switch conditioned for raw

temp = naccTable.UDSVERLC; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.UDSVERLC = temp; % switch conditioned for raw

temp = naccTable.UDSVERLR; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.UDSVERLR = temp; % switch conditioned for raw

temp = naccTable.UDSVERLN; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.UDSVERLN = temp; % switch conditioned for raw

temp = naccTable.UDSVERTN; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.UDSVERTN = temp; % switch conditioned for raw

temp = naccTable.UDSVERTE; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.UDSVERTE = temp; % switch conditioned for raw

temp = naccTable.UDSVERTI; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.UDSVERTI = temp; % switch conditioned for raw

temp = naccTable.COGSTAT; % set temp vector
temp(temp==0) = NaN; % set physician unable to NaN
temp(temp==9) = NaN; % set missing data to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (max(temp) - temp) / max(max(temp) - temp); % scale [0,1]
naccTable.COGSTAT = temp; % switch conditioned for raw

temp = naccTable.MOCATOTS; % set temp vector
temp(temp==88) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MOCATOTS = temp; % switch conditioned for raw

temp = naccTable.MOCATRAI; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCATRAI = temp; % switch conditioned for raw

temp = naccTable.MOCACUBE; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCACUBE = temp; % switch conditioned for raw

temp = naccTable.MOCACLOC; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCACLOC = temp; % switch conditioned for raw

temp = naccTable.MOCACLON; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCACLON = temp; % switch conditioned for raw

temp = naccTable.MOCACLOH; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCACLOH = temp; % switch conditioned for raw

temp = naccTable.MOCANAMI; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MOCANAMI = temp; % switch conditioned for raw

temp = naccTable.MOCAREGI; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MOCAREGI = temp; % switch conditioned for raw

temp = naccTable.MOCADIGI; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MOCADIGI = temp; % switch conditioned for raw

temp = naccTable.MOCALETT; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCALETT = temp; % switch conditioned for raw

temp = naccTable.MOCASER7; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MOCASER7 = temp; % switch conditioned for raw

temp = naccTable.MOCAREPE; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MOCAREPE = temp; % switch conditioned for raw

temp = naccTable.MOCAFLUE; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCAFLUE = temp; % switch conditioned for raw

temp = naccTable.MOCAABST; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MOCAABST = temp; % switch conditioned for raw

temp = naccTable.MOCARECN; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MOCARECN = temp; % switch conditioned for raw

temp = naccTable.MOCARECC; % set temp vector
temp(temp==88) = NaN; % set  problem NaN
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MOCARECC = temp; % switch conditioned for raw

temp = naccTable.MOCARECR; % set temp vector
temp(temp==88) = NaN; % set  problem NaN
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.MOCARECR = temp; % switch conditioned for raw

temp = naccTable.MOCAORDT; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCAORDT = temp; % switch conditioned for raw

temp = naccTable.MOCAORMO; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCAORMO = temp; % switch conditioned for raw

temp = naccTable.MOCAORYR; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCAORYR = temp; % switch conditioned for raw

temp = naccTable.MOCAORDY; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCAORDY = temp; % switch conditioned for raw

temp = naccTable.MOCAORPL; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCAORPL = temp; % switch conditioned for raw

temp = naccTable.MOCAORCT; % set temp vector, 0 no, 1 yes
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
naccTable.MOCAORCT = temp; % switch conditioned for raw

temp = naccTable.CRAFTVRS; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CRAFTVRS = temp; % switch conditioned for raw

temp = naccTable.CRAFTURS; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CRAFTURS = temp; % switch conditioned for raw

temp = naccTable.CRAFTDVR; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CRAFTDVR = temp; % switch conditioned for raw

temp = naccTable.CRAFTDRE; % set temp vector
temp(temp==95) = NaN; % set  problem NaN
temp(temp==96) = NaN; % set behavioral problem to NaN
temp(temp==97) = NaN; % set other problem to NaN
temp(temp==98) = NaN; % set verbal refusal to NaN
temp(temp==-4) = NaN; % set missing data to NaN
temp = (temp - min(temp)) / max(temp - min(temp)); % scale [0,1]
naccTable.CRAFTDRE = temp; % switch conditioned for raw

% show a historgram as a check
% hist(naccTable.CRAFTCUE)

% show first 10 rows of table as debug
% head(naccTable,200)

% get reduced set of column headings after curation
vNamesCurated = naccTable.Properties.VariableNames';
CnameNACC = vNamesCurated;

% store the conditioned NACC dataset
NACCdataset = table2array(naccTable);

% extract In and desOut from naccTable
% (note: In throws out the ID numbers)
In     = table2array(naccTable(:,2:102));
desOut = table2array(naccTable(:,103:end)); 

% save column names separately for In and desOut
CnameNACCin  = CnameNACC(2:102);
CnameNACCout = CnameNACC(103:end);

% find numbers of inputs and outputs
nIn  = size(In,2);
nOut = size(desOut,2);

% change NaNs in desOut to zeros for plotting
desOutPlot = desOut;
desOutPlot(isnan(desOutPlot)) = 0;

% comment in if plots are not needed
% return

% show In and desOut as images
figure(7)
clf
subplot(1,2,1)
imagesc(In)
xlabel('input number')
ylabel('pattern number')
title('Input')
subplot(1,2,2)
imagesc(desOutPlot)
xlabel('output number')
title('Desired Output')

return

% show In zoomed in
figure(8)
clf
imagesc(In(115:130,1:10))
xlabel('input number')
ylabel('pattern number')
title('Input Zoomed In')


