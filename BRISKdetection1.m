%% Copyright 2011-2013 The MathWorks, Inc.                                 
% This is a simple demo to visualize SURF features of the video data. 
% 
% Original version created by Takuya Otani
% Senior Application Engineer, MathWorks, Japan
% 
% MODIFIED FOR SAR PROJECT -- NICHOLAS HOLL 2021


clear all; close all;

ref_img = imread('migimage.bmp');
% ref_img_gray = rgb2gray(ref_img);
padded = padarray(ref_img',10);
ref_img_gray = padarray(padded', 10);
ref_img_gray = imresize(ref_img_gray,4);
% ref_img_gray = imresize(ref_img,4);

% windowSize = 5;
% avg3 = ones(windowSize) / windowSize^2;
% newblur = imfilter(ref_img_gray, avg3, 'conv');
% figure
% imshow(newblur)
% 
% ref_img_gray = newblur;

ref_pts = detectSURFFeatures(ref_img_gray);
[ref_features,  ref_validPts] = extractFeatures(ref_img_gray,  ref_pts);

figure; imshow(ref_img_gray);
hold on; plot(ref_pts.selectStrongest(5));

% figure;
% subplot(5,2,3); title('First 10 Features');
% for i=1:10
%     scale = ref_pts(i).Scale;
%     image = imcrop(ref_img,[ref_pts(i).Location-10*scale 20*scale 20*scale]);
%     subplot(5,2,i);
%     imshow(image);
%     hold on;
%     rectangle('Position',[5*scale 5*scale 10*scale 10*scale],'Curvature',1,'EdgeColor','g');
% end


image = imread('fullimage2.png');
% I = rgb2gray(image);
I = imresize(image,4);  % Rescaling attempt
% I = adapthisteq(I); % Auto Contrast Adjustment

% Detect features
I_pts = detectSURFFeatures(I);
[I_features, I_validPts] = extractFeatures(I, I_pts);
figure;imshow(I);
hold on; plot(I_pts.selectStrongest(75));


index_pairs = matchFeatures(ref_features, I_features);

ref_matched_pts = ref_validPts(index_pairs(:,1)).Location;
I_matched_pts = I_validPts(index_pairs(:,2)).Location;

figure, showMatchedFeatures(image, ref_img, I_matched_pts, ref_matched_pts, 'montage');