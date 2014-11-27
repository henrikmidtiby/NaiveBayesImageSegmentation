function segmentedImage = segmentImage(img, classifier, featureExtractor)

% Load new image
myfilter = fspecial('gaussian',[3 3], 1);
img = imfilter(img, myfilter, 'replicate');
temp = featureExtractor(img);
featureMatrix = single(temp);

% Segment image using classifier
vegProp = classifier.classify(featureMatrix);

% Reorganize pixels to the input image shape
segmentedImage = reshape(vegProp, size(img(:, :, 1)));

%figure(3); imagesc(segmentedImage); axis equal; colormap(gray);
%pause(0.1);

end