%Function loads images of white male and female

function [IM_WM_1,IM_WW_1] = loadImages()

% Load white male images 
for n = 1: 100
    IM_WM_1{n} = imread(['C:\Users\nsait\OneDrive\Cambridge University Projects\vocal_expressions_study\wm_1\wm_1\' num2str(n) '.png']);
end 


% Load white female images
 for n = 1: 100
     IM_WW_1{n} = imread(['C:\Users\nsait\OneDrive\Cambridge University Projects\vocal_expressions_study\wf_1\wf_1\' num2str(n) '.png']);
 end 
end