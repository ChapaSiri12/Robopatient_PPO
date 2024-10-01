clc;clear;close all;
%%

for i = 1:2
sound = audioread("painsoundmale"+string(i)+".wav");

hold on;
subplot(2,1,i);

plot(sound);
ylabel("$A$","Interpreter","latex");
end
xlabel("$t (s)$","Interpreter","latex");

set(0,'DefaultAxesFontSize',8); %Eight point Times is suitable typeface for an IEEE paper. Same as figure caption size
set(0,'DefaultFigureColor','w')
set(0,'defaulttextinterpreter','tex') %Allows us to use LaTeX maths notation
set(0, 'DefaultAxesFontName', 'times');

set(gcf, 'Units','centimeters')
set(gcf, 'Position',[0 0 8.89 4]);