clear; close all;

onion = im2gray(imread('migimage.bmp'));
peppers = im2gray(imread('fullimage2.png'));
montage({peppers,onion})

c = normxcorr2(onion,peppers);
figure
surf(c)
shading flat

[ypeak,xpeak] = find(c==max(c(:)));

yoffSet = ypeak-size(onion,1);
xoffSet = xpeak-size(onion,2);

figure
imshow(peppers)
drawrectangle(gca,'Position',[xoffSet,yoffSet,size(onion,1),size(onion,2)], ...
    'FaceAlpha',0);

peppers(yoffSet:yoffSet+size(onion,2),xoffSet:xoffSet+size(onion,1)) = 0;

% figure
% imshow(peppers)
% pause(0.1)
c = normxcorr2(onion,peppers);
% figure
% surf(c)
shading flat

[ypeak,xpeak] = find(c==max(c(:)));

yoffSet = ypeak-size(onion,1);
xoffSet = xpeak-size(onion,2);

% figure
imshow(peppers)
drawrectangle(gca,'Position',[xoffSet,yoffSet,size(onion,1),size(onion,2)], ...
    'FaceAlpha',0);
% figure
% imshow(peppers)
pause(0.5)

peppers(yoffSet:yoffSet+size(onion,2),xoffSet:xoffSet+size(onion,1)) = 0;

c = normxcorr2(onion,peppers);
% figure
% surf(c)
shading flat

[ypeak,xpeak] = find(c==max(c(:)));

yoffSet = ypeak-size(onion,1);
xoffSet = xpeak-size(onion,2);

% figure
imshow(peppers)
drawrectangle(gca,'Position',[xoffSet,yoffSet,size(onion,1),size(onion,2)], ...
    'FaceAlpha',0);

% imshow(peppers)
pause(0.5)