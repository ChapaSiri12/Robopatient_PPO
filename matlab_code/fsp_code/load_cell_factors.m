clc;clear;close all;
%%
% 3 trials per load cell
loadCellFact1 = [3.941860923151712e+04 4.047714262349968e+04 4.066774382506262e+04];
meanLoadCellFac1 = mean(loadCellFact1);

disp("Load Cell 1 Fact: " + string(meanLoadCellFac1));

loadCellFact2 = [4.120967301446085e+04 4.180744508863855e+04 4.110675802020842e+04];
meanLoadCellFac2 = mean(loadCellFact2);

disp("Load Cell 2 Fact: " + string(meanLoadCellFac2));

loadCellFact3 = [4.085099646044886e+04 4.068577504749623e+04 4.085317263525341e+04];
meanLoadCellFac3 = mean(loadCellFact3);

disp("Load Cell 3 Fact: " + string(meanLoadCellFac3));

loadCellFact4 = [4.039095747929098e+04 4.080398827588656e+04 4.026125335163919e+04];
meanLoadCellFac4 = mean(loadCellFact4);

disp("Load Cell 4 Fact: " + string(meanLoadCellFac4));