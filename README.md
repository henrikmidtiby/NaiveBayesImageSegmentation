Statistics-Based Segmentation Using a Continuous-Scale Naive Bayes Approach
===========================================================================

This repository contains the Matlab scripts used for obtaining the results
described in [Statistics-Based Segmentation Using a Continuous-Scale Naive Bayes Approach](http://dx.doi.org/10.1016/j.compag.2014.10.009 "DOI lookup").
If you use this work please cite the paper above in any publications.

To get started you may wish to look into exampleUsage.m explained in details 
below.

First we add the scripts to our Matlab path.
    ```matlab
    %%
    % Script for training naive bayes classifier and using it for segmenting 
    % images based on colour indices.
    path(path, './scripts/');
    ```

Then we specify the color features we wish to use for our classifier by their
index as defined in calculateColourFeatures.m
    ```matlab
    %% Define featureset, trainingset, testimage and other paths
    % Features used in the bayes paper
    selectedFeatures = [1, 2, 3, 11, 12, 13, 4, 5, 6, 7, 8, 9, 10, 14, 15, 16];
    ```

We then create a function handle for our selected features, that we can use to
refer to our selected features and their implementation from now on
    ```matlab
    featureExtractor = @(img) calculateColourFeatures(img, selectedFeatures);
    ```

Then we move onto defining our training set, with both the unaltered input images
and the annotated examples (The software will only look at white and black labels
and images can therefore be partly annotated, which is typically the most 
efficient way to quickly span the space of your dataset).
    ```matlab
    % Define paths
    trainingImagePath = fullfile('trainingimages','trainingimage.png');
    vegetationMapPath = fullfile('trainingimages','trainingimageannotated.png');
    ```
    
We can then train our classifier using the training data and featureExtractor
from above.
    ```matlab
    %% Train classifier
    [classifier, featureMatrix, featureNames] = trainClassifierFromImagePair(trainingImagePath,...
                                                          vegetationMapPath, featureExtractor);
    ```
    
Now to apply our classifier in this case just on a image from the training set,
but could be any image for which the training was suitable.
    ```matlab
    %% Apply classifier to image
    img = readRGBorRGBNimage(trainingImagePath);
    ```
    
Which allows us to segment the image using the classifier and write the result
to disk
    ```matlab
    res = segmentImage(img, classifier, featureExtractor);
    classificationPath = fullfile('trainingimages','segmentedImage.png');
    imwrite(res, classificationPath);
    ```