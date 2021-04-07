%% Train Fast R-CNN Stop Sign Detector
clear; close all;
%%
% Load training data.
% data = load('rcnnStopSigns.mat', 'migTable', 'fastRCNNLayers');
data = load('rcnnStopSigns.mat','fastRCNNLayers');
data1 = load('tableORIG');
stopSigns = data1.tableORIG;
fastRCNNLayers = [
    imageInputLayer([256 256 1])
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(3)
    softmaxLayer
    classificationLayer]

%%
% Add fullpath to image files.
% stopSigns.imageFilename = fullfile(toolboxdir('vision'),'visiondata', ...
%     stopSigns.imageFilename);

%%
% Set network training options:
%
% * Lower the InitialLearningRate to reduce the rate at which network
%   parameters are changed.
% * Set the CheckpointPath to save detector checkpoints to a temporary
%   directory. Change this to another location if required.
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 1e-6, ...
    'MaxEpochs', 10, ...
    'CheckpointPath', tempdir);

%%
% Train the Fast R-CNN detector. Training can take a few minutes to complete.
frcnn = trainFastRCNNObjectDetector(stopSigns, fastRCNNLayers , options, ...
    'NegativeOverlapRange', [0 0.1], ...
    'PositiveOverlapRange', [0.7 1], ...
    'SmallestImageDimension', 256);

%%
% Test the Fast R-CNN detector on a test image.
img = imread('origscene.png');

%% 
% Run the detector.
[bbox, score, label] = detect(frcnn, img);

%%
% Display detection results.
% detectedImg = insertShape(img, 'Rectangle', bbox);
imshow(img)
biig = size(bbox);
for i = 1:biig(1)
    if score(i) > 0.9
        drawrectangle('Label',char(label(i)),'Position',bbox(i,:));
    end
end
% figure
% imshow(detectedImg)