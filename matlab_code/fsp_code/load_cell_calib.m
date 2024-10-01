clear;clc;close all;
%% config channels

device = daq("ni");

channel1 = addinput(device,"Dev1","ai1","Voltage");
channel1.Range = [-0.2 0.2];

sampleRate = 1000;

device.Rate = sampleRate;

%% initialisation
mvToNFactor1 = 4.048539970227224e+04;

ani1 = animatedline('Color','r','LineWidth',2);
ylim([-20 20]);
title("Load Cell");

%movAvg = dsp.MovingAverage(10);
% calibrationFactor=1.0;
%% Milli Volts to Newtons calibration

duration = 10;
readings = 10000;

weight1 = 0.5 * 9.8 ;
weight2 = 1.0 * 9.8 ;
weight3 = 1.5 * 9.8 ;

% 0.5kg

prompt = input("Add Weight 1 and Press 1");

if (prompt == 1)

    start(device,"Duration",seconds(duration));
    [data,~] = read(device,readings,"OutputFormat","Matrix");

    mvMeanWeight1 =  mean(data(:,1));  %in N
end

% 1.0kg

prompt = input("Add Weight 2 and Press 1");

if (prompt == 1)

    start(device,"Duration",seconds(duration));
    [data,~] = read(device,readings,"OutputFormat","Matrix");

    mvMeanWeight2 =  mean(data(:,1));  %in N
end

% 1.5kg

prompt = input("Add Weight 3 and Press 1");

if (prompt == 1)

    start(device,"Duration",seconds(duration));
    [data,~] = read(device,readings,"OutputFormat","Matrix");

    mvMeanWeight3 =  mean(data(:,1));  %in N
end

mvMean = [mvMeanWeight1 mvMeanWeight2 mvMeanWeight3];
weights = [weight1 weight2 weight3];

mvNewCoeff = polyfit(mvMean,weights,1);
mvToNFactor = mvNewCoeff(1);
disp("Milli Volt to New Fact: " + string(mvToNFactor));

figure;
plot(mvMean,weights);
title("Milli Volts to Newton Fac" + string(mvToNFactor));

%% Minimum Calibration 10s

duration = 3;
readings = 3000;

start(device,"Duration",seconds(duration));

[data,~] = read(device,readings,"OutputFormat","Matrix");

loadCell1 =  data(:,1) * mvToNFactor1;  %in N

meanWeight = mean(loadCell1);

stop(device);
%% main
% calibrationFactor=1+(referenceWeight)/2;
calibrationFactor=1;

device.ScansAvailableFcn = @(src,evt) plotFcn(device,evt,mvToNFactor1,meanWeight,ani1);
device.ScansAvailableFcnCount = 200;
start(device,"Duration",seconds(30));

function plotFcn(src,~,mvToNFactor1,meanWeight,ani1)

[data,timeStamps,~] = read(src,src.ScansAvailableFcnCount,"OutputFormat","Matrix");

loadCell1 =  ((data * mvToNFactor1) - meanWeight) ;  %in N

addpoints(ani1,timeStamps(:,1),loadCell1);
drawnow limitrate;
end


