% RADCreadLongBasic.m
% this script reads the Excel file containing 
% the whole RACD dataset (dataset_621_long) as well
% as the demographics dataset (dataset_621_basic); 
% dataset621long has 26200 rows and 137 columns; 
% datase621basic has 3329 rows and 16 columns;
% the first row in both is text for column heads 
% note that these Exel files are edited from the
% original RADC datastes 

% read all text and numerical data from dataset621long
% (note: this block reads directly into arrays --
%  it can be used but does NOT reorder drug columns)
% (N is the numerical data array)
% (T is the array of all text)
% [N621long T621long] = xlsread('dataset621long',1,'A1:EG26200');
% note: column 128 of N621long is all either 0 or NaN
% this column is other_dietary_rx
% remove this column from N621long and T621long
% N621long = [N621long(:,1:127) N621long(:,129:end)];
% T621long = [T621long(1:127)   T621long(129:end)];
% grab the column names from T
% Cname621long = char(T621long(1,2:end));

% read all text and numerical data from dataset621long
% (note: this block reads directly into a table first,
%  then rearranges some variables, then saves as arrays)
radcLongTable = readtable('dataset621long.xlsx'); 
% note: column other_dietary_rx is all either 0 or NaN
% remove this column from radcLongTable
radcLongTable = removevars(radcLongTable,{'other_dietary_rx'});
% move some drug variables to agree with NACC
radcLongTable = movevars(radcLongTable,'ad_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'park_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'antianxiety_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'antipsychotic_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'depression_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'antiadrenergics_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'estrogens_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'diabetes_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'lipid_lowering_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'anticoagulant_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'antianginal_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'diuretic_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'beta_block_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'calcium_channel_block_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'take_arbs_rx','after','analgesic_rx');
radcLongTable = movevars(radcLongTable,'aceinhibitor_rx','after','analgesic_rx');

% show first 10 rows of table as debug
% head(radcLongTable,10)

% store the conditioned RADC dataset
N621long = table2array(radcLongTable);

% hold N for reference
N621longHold = N621long;

% get reduced set of column headings after curation
T621long = radcLongTable.Properties.VariableNames';

% grab the column names of T
% (note: keep cell array format)
Cname621long = T621long;

% find the column sizes
numC621long = size(Cname621long,1);

% read all text and numerical data from dataset621basic
% (N is the numerical data array)
% (T is the array of all text)
[N621basic T621basic] = xlsread('dataset621basic',1,'A1:P3329');
% hold N for reference
N621basicHold = N621basic;
% grab the column names from T
Cname621basic = T621basic(1,2:end)';
% find the column sizes
[numC621basic] = size(Cname621basic,1);

% the columns of N621long are:
% col 1, IDnum; col 2, visit; cols 3:27, cts; col 28, age; 
% cols 29:37, comorbidity; cols 38:137, drugs
% the columns of N621basic are:
% col 1, IDnum; col 2, age; col 3, death age; col 4, education; 
% col 5, msex; col 6, race; col 7, spanish; cols 8:16, comorbidity

