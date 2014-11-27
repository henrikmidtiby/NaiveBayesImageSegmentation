function [classifier, featureMatrix, featureNames] = trainClassifierFromImagePair(origImage, annotatedImage, featureExtractor)

%% Segmentation of database images based on Naive Bayes
img = readRGBorRGBNimage(origImage);

% Smooth input image
myfilter = fspecial('gaussian',[3 3], 1);
img = imfilter(img, myfilter, 'replicate');

segmented = double(imread(annotatedImage));
segmented = (segmented(:, :, 1) + segmented(:, :, 2) + segmented(:, :, 3)) / 3;

[featureMatrix, bandwidths, featureNames] = featureExtractor(img);

%% Extract pixel values
highthreshold = 254;
vegetation = extractTrainingFeatures(segmented > highthreshold, featureMatrix);
assert(length(vegetation) > 0);

lowthreshold = 2;
background = extractTrainingFeatures(segmented < lowthreshold, featureMatrix);
assert(length(background) > 0);


%% Train classifier
fprintf('Training classifier with %d samples of vegetation and %d samples of soil\n', ...
    length(vegetation), length(background));
classifier = NaiveBayesClassifier();
classifier = classifier.trainClassifier(vegetation, background, bandwidths, 255);

end