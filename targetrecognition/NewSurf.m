clear; close all;

Ib=imread('migimage.bmp'); %object image
padded = padarray(Ib',10);
Ib = padarray(padded', 10);
Ib = imresize(Ib,4);
Is=imread('fullimage2.png'); % scene image
Is = imresize(Is,4);
% Ib=rgb2gray(Ib);
% Is=rgb2gray(Is);
regionsb = detectSURFFeatures(Ib);
regionss = detectSURFFeatures(Is);
[featuresb, validPtsObjb] = extractFeatures(Ib, regionsb);
[featuress, validPtsObjs] = extractFeatures(Is, regionss);

figure; imshow(Ib);
hold on; plot(regionsb.selectStrongest(5));
figure;imshow(Is);
hold on; plot(regionss.selectStrongest(75));

bPairs = matchFeatures(featuresb, featuress);
matchedBPoints = regionsb(bPairs(:, 1), :);
matchedSPoints = regionss(bPairs(:, 2), :);
figure;
showMatchedFeatures(Ib, Is, matchedBPoints, matchedSPoints, 'montage');
title('Putatively Matched Points (Including Outliers)');
[tform, inlierBPoints, inlierSPoints] = estimateGeometricTransform(matchedBPoints, matchedSPoints, 'affine');
figure;
showMatchedFeatures(Ib, Is, inlierBPoints, inlierSPoints, 'montage');
title('Matched Points (Inliers Only)');
bPolygon = [1, 1;...                           % top-left
        size(Ib, 2), 1;...                 % top-right
        size(Ib, 2), size(Ib, 1);... % bottom-right
        1, size(Ib, 1);...                 % bottom-left
        1, 1];    
      newBPolygon = transformPointsForward(tform, bPolygon);
      figure;
  imshow(Is);
  hold on;
  line(newBPolygon(:, 1), newBPolygon(:, 2), 'Color', 'y');
  title('Detected Box');