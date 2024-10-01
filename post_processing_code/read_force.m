clc;clear;close all;
%% Read Data

% Subject and trail number
subjectNum = 7;
trialNum = 24;
gender = "Male";
%gender = "Female";

% force data
forceData = readtable("S" + string(subjectNum) + "\" + gender + "\T" + string(trialNum) + ...
    " S"+ string(subjectNum) + ".txt");
forceDataConv = table2array(forceData);


expData = readtable("S" + string(subjectNum) + "\" + gender + "\S" + string(subjectNum) + ...
    " Exp T120.txt");

forceThresh = table2array(expData(:,2));

%% Basic data 

% Raw time and force
time = forceDataConv(:,1);
force = forceDataConv(:,2);

plot(time,force,'LineWidth',2);
xlabel("Time (s)");
ylabel("Force (N)");
title("S" + string(subjectNum) + ", Gender: " + gender + ", Trial: " + string(trialNum));
%%

% Max force
maxForce = max(force);
numDataPoints = numel(time);

% Time stamp of max force
for i = 1:numDataPoints

    forceVal = force(i);

    if forceVal == maxForce
        timeVal = time(i);
    end
end

% Force thresh for trial
forceThreshTrial = forceThresh(trialNum,1);

%% Plot

hold on;
plot(time,force);
scatter(timeVal,maxForce,"Marker","o");
scatter(timeVal,forceThreshTrial,"Marker","*");

title("Subject: " + string(subjectNum) + ", Trail: " + string(trialNum));
xlabel("Time (s)");
ylabel("Force (N)");
legend(["Raw Force","Maximum Force","Force Threshold"]);

text(timeVal,maxForce, "    "+ string(maxForce));
text(timeVal,forceThreshTrial, "  "+ string(forceThreshTrial));
