clear;clc;
[num txt raw] = xlsread('ECP.xlsx',2)
genesym_AgilentID = raw(3:end,1:2);
AgilentID_proteases = raw(3:end,2);
[~, ~, day1] = xlsread('ECP.xlsx',3);
[~, ~, day3] = xlsread('ECP.xlsx',4);
[~, ~, day5] = xlsread('ECP.xlsx',5);
[~, ~, day7] = xlsread('ECP.xlsx',6);
day1 = day1(2:end,:);
day3 = day3(2:end,:);
day5 = day5(2:end,:);
day7 = day7(2:end,:);

%pick out proteases
[C, ia, ib] = intersect(day1(:,1), AgilentID_proteases);
day1_proteases = day1(ia,:);

[C, ia, ib] = intersect(day3(:,1), AgilentID_proteases);
day3_proteases = day3(ia,:);

[C, ia, ib] = intersect(day5(:,1), AgilentID_proteases);
day5_proteases = day5(ia,:);

[C, ia, ib] = intersect(day7(:,1), AgilentID_proteases);
day7_proteases = day7(ia,:);