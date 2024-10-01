clear;clc;close all;
%% config channels

device = daq("ni");

channel1 = addinput(device,"Dev2","ai1","Voltage");
channel1.Range = [-0.2 0.2];

channel2 = addinput(device,"Dev2","ai2","Voltage");
channel2.Range = [-0.2 0.2];

channel3 = addinput(device,"Dev2","ai3","Voltage");
channel3.Range = [-0.2 0.2];

channel4 = addinput(device,"Dev2","ai4","Voltage");
channel4.Range = [-0.2 0.2];

sampleRate = 1000;

device.Rate = sampleRate;

%% initialisation

mvToNewFactor = [4.018783189335981e+04 4.137462537443594e+04 4.079664804773283e+04 4.048539970227224e+04]; %1,2,3,4

sub1 = subplot(5,1,1);
ylim([-20 20]);
% axis([0 21 -1.1 1.1]);
ani1 = animatedline('Color','r','LineWidth',2);
title("Load Cell 1");

subplot(5,1,2)
ylim([-20 20]);
% axis([0 21 -1.1 1.1]);
ani2 = animatedline('Color','k','LineWidth',2);
title("Load Cell 2");

subplot(5,1,3);
ylim([-20 20]);
% axis([0 21 -1.1 1.1]);
ani3 = animatedline('Color','g','LineWidth',2);
title("Load Cell 3");

subplot(5,1,4)
ylim([-20 20]);
% axis([0 21 -1.1 1.1]);
ani4 = animatedline('Color','b','LineWidth',2);
title("Load Cell 4");
ylim([-20 20]);

subplot(5,1,5)
ylim([-25 25]);
ani5 = animatedline('Color','m','LineWidth',2);
title("Total Force(N)");

%movAvg = dsp.MovingAverage(10);
% calibrationFactor=1.0;
%% Minimum Calibration, no weight

duration = 2;

[data,~] = read(device,duration,"OutputFormat","Matrix");

loadCell1 =  data(:,1)*mvToNewFactor(:,1);  %in N
loadCell2 =  data(:,2)*mvToNewFactor(:,2);  %in N
loadCell3 =  data(:,3)*mvToNewFactor(:,3);  %in N
loadCell4 =  data(:,4)*mvToNewFactor(:,4);  %in N


baseForce = loadCell1 + loadCell2 + loadCell3 + loadCell4; %in N

referenceNoWeight=[mean(loadCell1),mean(loadCell2),mean(loadCell3),mean(loadCell4)];

%% Weight Calibration

duration = 2;

[data,~] = read(device,duration,"OutputFormat","Matrix");

loadCell1 =  data(:,1)*mvToNewFactor(:,1);  %in N
loadCell2 =  data(:,2)*mvToNewFactor(:,2);  %in N
loadCell3 =  data(:,3)*mvToNewFactor(:,3);  %in N
loadCell4 =  data(:,4)*mvToNewFactor(:,4);  %in N

baseForce = loadCell1-referenceNoWeight(1) + loadCell2-referenceNoWeight(2) + loadCell3-referenceNoWeight(3) + loadCell4-referenceNoWeight(4); %in N

referenceWeight=mean(baseForce);

%% Maximum Calibration 10s

duration = 10;

[data,~] = read(device,duration,"OutputFormat","Matrix");

loadCell1 =  data(:,1)*mvToNewFactor(:,1);  %in N
loadCell2 =  data(:,2)*mvToNewFactor(:,2);  %in N
loadCell3 =  data(:,3)*mvToNewFactor(:,3);  %in N
loadCell4 =  data(:,4)*mvToNewFactor(:,4);  %in N


baseForce = loadCell1-referenceNoWeight(1) + loadCell2-referenceNoWeight(2) + loadCell3-referenceNoWeight(3) + loadCell4-referenceNoWeight(4); %in N

referenceMean=mean(baseForce);
%% main
% calibrationFactor=1+(referenceWeight)/2;
calibrationFactor=1;

for timeStep = 1:10001

    data = read(device,"OutputFormat","Matrix");

    loadCell1 =  data(:,1)*mvToNewFactor(:,4)-referenceNoWeight(1);  %in N
    loadCell2 =  data(:,2)*mvToNewFactor(:,1)-referenceNoWeight(2);  %in N
    loadCell3 =  data(:,3)*mvToNewFactor(:,3)-referenceNoWeight(3);  %in N
    loadCell4 =  data(:,4)*mvToNewFactor(:,2)-referenceNoWeight(4);  %in N

    totalForceBeforeCal(:,1) = [loadCell1,loadCell2,loadCell3,loadCell4]; %in N
    totalForceAfterCal = round(calibrationFactor*(sum(totalForceBeforeCal)),2); % find the calibrationFactor

    force = round(100*totalForceAfterCal/40);

    addpoints(ani1,timeStep,loadCell1);
    addpoints(ani2,timeStep,loadCell2);
    addpoints(ani3,timeStep,loadCell3);
    addpoints(ani4,timeStep,loadCell4);
    addpoints(ani5,timeStep,totalForceAfterCal);
    drawnow limitrate

end
