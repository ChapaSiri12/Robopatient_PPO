
function [RI_WM1,RI_WW1,targetSize,ang,alpha] = rotateImages(IM_WM_1,IM_WW_1)

targetSize = [500 360];
alpha = 2;
ang = -90;

for g = 1: 100
    r_img = centerCropWindow2d(size(IM_WM_1{g}),targetSize);
    j_img = imcrop(IM_WM_1{g},r_img);
    t_img = imrotate(j_img ,ang);
    RI_WM1{g} = imresize(t_img, alpha);
end

for g = 1: 100
    r_img = centerCropWindow2d(size(IM_WW_1{g}),targetSize);
    j_img = imcrop(IM_WW_1{g},r_img);
    t_img = imrotate(j_img ,ang);
    RI_WW1{g} = imresize(t_img, alpha);
end

end