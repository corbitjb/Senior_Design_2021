%% Train Fast R-CNN Stop Sign Detector

%%
% Load training data.
% data = load('rcnnStopSigns.mat', 'migTable', 'fastRCNNLayers');
data = load('rcnnStopSigns.mat','fastRCNNLayers');
data1 = load('migTableORIG');
stopSigns = data1.migORIG;
fastRCNNLayers = data.fastRCNNLayers;

%% CREATE NETWORK
newFastRCNNLayers = [
    imageInputLayer([32 32 3])
    
    convolution2dLayer(3,32,'Padding','same')
%     batchNormalizationLayer
    reluLayer
    
%     maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
%     batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
%     convolution2dLayer(3,32,'Padding','same')
%     batchNormalizationLayer
%     reluLayer
    fullyConnectedLayer(64)
    reluLayer
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

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

% options = trainingOptions('sgdm', ...
%     'InitialLearnRate', 1e-6, ...
%     'MaxEpochs', 20, ...
%     'CheckpointPath', tempdir);


%% Alternate training options
% options = trainingOptions('sgdm', ...
%     'InitialLearnRate',0.01, ...
%     'MaxEpochs',4, ...
%     'Shuffle','every-epoch', ...
%     'ValidationData',imdsValidation, ...
%     'ValidationFrequency',30, ...
%     'Verbose',false, ...
%     'Plots','training-progress');

options = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.01, ...
    'MaxEpochs', 4, ...
    'CheckpointPath', tempdir);

%%
% Train the Fast R-CNN detector. Training can take a few minutes to complete.
frcnn = trainFastRCNNObjectDetector(stopSigns, newFastRCNNLayers , options, ...
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
detectedImg = insertShape(img, 'Rectangle', bbox);
figure
imshow(detectedImg)