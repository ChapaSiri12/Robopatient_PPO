clc;clear;close all;

%% Load data

% Variables to change ------------
numTrials = 120;
numSub = 5;
%----------------------------------

choiceTotal = zeros(numSub,4);
colIndex = 1;

for k = 1:numSub

    subjectNum = k + 3;
    gender = "Male";
    colIndex = 1;

    for j = 1:2

        %read exp data
        expData = readtable("S" + string(subjectNum) + "\" + gender + "\S" + string(subjectNum) + ...
            " Exp T120.txt");

        % main

        %counters for choice
        agreeCount = 0;
        disagreeCount = 0;

        %change trials with no choice to '0'
        choices = expData(:,6);
        choices = table2array(choices);
        choices(isnan(choices)) = 0;

        for i=1:numTrials
            choice = choices(i);

            if choice == 0
                disagreeCount = disagreeCount + 1;
            elseif choice == 1
                agreeCount = agreeCount + 1;
            end
        end

        choiceTotal(k,[colIndex colIndex+1]) = ([agreeCount disagreeCount] / numTrials) * 100;

        gender = "Female";
        colIndex = 3;
    end
end

boxchart(choiceTotal);
xticklabels(["Agree Male","Disagree Male","Agree Female","Disagree Female"]);
ylabel("Total Choice Rate (%)");
