%% Train Fast R-CNN Stop Sign Detector

%%
% Load training data.
% data = load('rcnnStopSigns.mat', 'migTable', 'fastRCNNLayers');
data = load('rcnnStopSigns.mat','fastRCNNLayers');
data1 = load('migTableORIG');
stopSigns = data1.migORIG;
fastRCNNLayers = data.fastRCNNLayers;

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
    'MaxEpochs', 20, ...
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
detectedImg = insertShape(img, 'Rectangle', bbox);
figure
imshow(detectedImg)