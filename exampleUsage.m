%%
% Script for training naive bayes classifier and using it for segmenting 
% images based on colour indices.
path(path, './scripts/');

%% Define featureset, trainingset, testimage and other paths
% Features used in the bayes paper
selectedFeatures = [1, 2, 3, 11, 12, 13, 4, 5, 6, 7, 8, 9, 10, 14, 15, 16];
selectedFeatures = selectedFeatures([1, 2, 3, 15, 4, 5, 6, 14, 10, 16]);
featureExtractor = @(img) calculateColourFeatures(img, selectedFeatures);

% Define paths
trainingImagePath = fullfile('trainingimages','trainingimage.png');
vegetationMapPath = fullfile('trainingimages','trainingimageannotated.png');
classificationPath = fullfile('trainingimages','segmentedImage.png');

%% Train classifier
[classifier, featureMatrix, featureNames] = trainClassifierFromImagePair(trainingImagePath, vegetationMapPath, featureExtractor);

%% Apply classifier to image
img = readRGBorRGBNimage(trainingImagePath);
res = segmentImage(img, classifier, featureExtractor);
imwrite(res, classificationPath);

