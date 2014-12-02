%
% Copyright (c) 2014, Morten Stigaard Laursen & Henrik Skov Midtiby
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation 
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
% OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
% WHETHER IN CONTRACT, STRICT LIABILITY, 
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
% THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% If you use this code please cite the paper "Statistics-based segmentation
% using a continuous-scale naive Bayes approach".
% The citation details are given below in bibtex
% @article{Laursen2014271,
%   title = "Statistics-based segmentation using a continuous-scale naive Bayes approach",
%   journal = "Computers and Electronics in Agriculture ",
%   volume = "109",
%   number = "0",
%   pages = "271 - 277",
%   year = "2014",
%   issn = "0168-1699",
%   doi = "http://dx.doi.org/10.1016/j.compag.2014.10.009",
%   url = "http://www.sciencedirect.com/science/article/pii/S0168169914002567",
%   author = "Morten Stigaard Laursen and Henrik Skov Midtiby and Norbert Krüger and Rasmus Nyholm Jørgensen",
% }
% 
classdef NaiveBayesClassifier
    properties
        npoints
        classAfeatureDensity
        classBfeatureDensity
        classAprior
        classBprior
        featureRangeLow
        featureRangeHigh
        featureBandwidths
        featureValueMatrix
    end % properties
    methods
        function obj = trainClassifier(obj, ...
                classAFeatures, classBFeatures, featureBandwidths, npointsIn)
            % Store number of points and feature bandwidths.
            obj.npoints = npointsIn;
            obj.featureBandwidths = featureBandwidths;
            
            % Calculate range of feature values \pm 10 times the bandwidth.
            combinedFeatures = vertcat(classAFeatures, classBFeatures);
            obj.featureRangeLow  = min(combinedFeatures) - 10*featureBandwidths;
            obj.featureRangeHigh = max(combinedFeatures) + 10*featureBandwidths;
            
            % Build feature value matrix.
            obj.featureValueMatrix = zeros(obj.npoints, size(combinedFeatures, 2));
            weights = ((1:obj.npoints) - 1) / (obj.npoints - 1);
            for index = 1:obj.npoints
                obj.featureValueMatrix(index, :) = ...
                    (1-weights(index)) * obj.featureRangeLow + ...
                    weights(index) * obj.featureRangeHigh;
            end
            
            % Build the feature density matrices.
            obj.classAfeatureDensity = zeros(obj.npoints, size(combinedFeatures, 2));
            obj.classBfeatureDensity = zeros(obj.npoints, size(combinedFeatures, 2));
            for k = 1:size(combinedFeatures, 2)
                temp = ksdensity(classAFeatures(:, k), ...
                    obj.featureValueMatrix(:, k), 'width', featureBandwidths(k));
                obj.classAfeatureDensity(:, k) = temp;
                temp = ksdensity(classBFeatures(:, k), ...
                    obj.featureValueMatrix(:, k), 'width', featureBandwidths(k));
                obj.classBfeatureDensity(:, k) = temp;
            end
            
            % Scale kernel densities to normalized range
            scaling = 1/mean([mean(obj.classAfeatureDensity(obj.classAfeatureDensity~=0)), mean(obj.classBfeatureDensity(obj.classBfeatureDensity~=0))]);
            obj.classAfeatureDensity = obj.classAfeatureDensity * scaling;
            obj.classBfeatureDensity = obj.classBfeatureDensity * scaling;
            
            % Set the class priors
            totalNumberOfTrainingSamples = size(classAFeatures, 1) + size(classBFeatures, 1);
            obj.classAprior = size(classAFeatures, 1) / totalNumberOfTrainingSamples;
            obj.classBprior = size(classBFeatures, 1) / totalNumberOfTrainingSamples;
        end 
        function classAPercentage = classify(obj, featureVector)
            % Determine indices of the corresponding feature values
            indices = 1 + 0*featureVector;
            for k = 1:size(featureVector, 2)
                indices(:, k) = ceil((featureVector(:, k) - obj.featureRangeLow(k)) ./ (obj.featureRangeHigh(k) - obj.featureRangeLow(k)) * obj.npoints);
            end
            id = indices < 1;
            indices(id) = 1;
            id = indices > obj.npoints;
            indices(id) = obj.npoints;
            
            densitiesA = 0*indices;
            densitiesB = 0*indices;
            for k = 1:size(indices, 2)
                densitiesA(:, k) = obj.classAfeatureDensity(indices(:, k), k);
                densitiesB(:, k) = obj.classBfeatureDensity(indices(:, k), k);
            end
            
            % Calculate the support for class A and class B respectively.
            % Value added to all support values before multiplication.
            % This ensures that ill defined cases will not disturb way to
            % much.
            weakval = 10^-10;
            % TODO: Scale with the number of training examples?
            supportA = obj.classAprior * prod(double(densitiesA) + weakval, 2);
            supportB = obj.classBprior * prod(double(densitiesB) + weakval, 2);
            
            % Calculate probability of belonging to class A.
            classAPercentage = supportA ./ (supportA + supportB);
            classAPercentage(supportA==0) = 0;
            classAPercentage(supportA==supportB) = 0.5;
            assert(any(isnan(classAPercentage))==0);
        end
        function showFeatureRanges(obj)
            disp(obj.featureRangeLow)
            disp(obj.featureRangeHigh)
        end
        function plotFeatureDensities(obj, titles)
            for k = 1:length(obj.featureRangeLow)
                figure(10+k);
                plot(obj.featureValueMatrix(:, k), obj.classAfeatureDensity(:, k), 'g', ...
                    obj.featureValueMatrix(:, k), obj.classBfeatureDensity(:, k), 'r', 'LineWidth', 2);
                title(titles(k));
                print(gcf, sprintf('plot/%s.png', titles{k}), '-dpng');
            end
        end
        function overlapRatios = calculateFeatureOverlaps(obj)
            minValues = sum(min(obj.classAfeatureDensity, obj.classBfeatureDensity));
            areaUnderCurves = sum(obj.classAfeatureDensity);
            overlapRatios = minValues ./ areaUnderCurves;
        end
        function createCorrelationFigure(obj, featureMatrix, featureNames)
            obj.createFeatureCorrelationTikzIllustration(featureMatrix, 'correlations/correlationFigure.tex', featureNames);
        end
        function visualizeFeatureCorrelation(obj, featureMatrix)
            % Calculate correlation coefficients
            R = corrcoef(featureMatrix);
            R = abs(R);
            
            figure(1);
            imagesc(R); colormap(gray);
            figure(2);
            imagesc(1-R); colormap(gray);
        end
        function createFeatureCorrelationTikzIllustration(obj, featureMatrix, filename, featureNames)
            % Calculate correlation coefficients
            R = corrcoef(featureMatrix);
            R = abs(R);
          
            % Export to drawing with tikz
            [X, Y] = meshgrid(1:size(featureMatrix, 2));
            
            ccm = [100-round(100*R(:)), X(:), Y(:)];
            ccm2 = [X(:), Y(:), R(:)];
            
            fh = fopen(filename, 'w');
            
            fprintf(fh, '\\documentclass{article}\n\\usepackage{tikz}\n');
            fprintf(fh, '\\usetikzlibrary{external}\n\\tikzexternalize\n');
            fprintf(fh, '\\begin{document}\n\\begin{tikzpicture}[scale=0.8]\n');
            fprintf(fh, '\\tikzstyle{correlationvalues}=[black, font=\\small]\n');
            fprintf(fh, '\\tikzstyle{correlationvalueslow}=[correlationvalues, white]\n');

            fprintf(fh, '\\fill[fill=black!%d] (%d, %d) rectangle ++(1, 1);\n', ccm');
            % Add different tikz style to correlation values below 0.5
            id = ccm2(:, 3) > 0.5;
            fprintf(fh, '\\draw[correlationvalues] (%d, %d) ++ (0.5, 0.5) node{%.2f};\n', ccm2(id, :)');
            fprintf(fh, '\\draw[correlationvalueslow] (%d, %d) ++ (0.5, 0.5) node{%.2f};\n', ccm2(~id, :)');

            fprintf(fh, '\\foreach \\x/\\lab in {');
            for k = 1:size(featureNames, 1)
                if(k ~= 1)
                    fprintf(fh, ',');
                end
                fprintf(fh, '%d/%s', k, featureNames{k});
            end
            fprintf(fh, '}\n{\n\\draw (\\x+0.5, 0.75) node[right, rotate=-90]{\\lab};\n');
            fprintf(fh, '\\draw (0.75,\\x+0.5) node[left]{\\lab};\n}\n');
            fprintf(fh, '\\draw[white] (1, 1) grid (11, 11);\n');
            fprintf(fh, '\\end{tikzpicture}\n\\end{document}\n');

            fclose(fh);
        end
        function featValMatrix = exportDensityPlotsToTikz(obj, directoryPath)
            mkdir(directoryPath)
            % Normalize data
            densities = obj.classAfeatureDensity + obj.classBfeatureDensity;
            densitySum = sum(densities);
            weightedSum = sum(densities .* obj.featureValueMatrix);
            weightedMeans = weightedSum ./ densitySum;
            weightedSqSum = sum(densities .* obj.featureValueMatrix.^2);
            weightedSqMeans = weightedSqSum ./ densitySum;
            % Not completely sure about this part
            weightedStd = sqrt(weightedSqMeans-weightedMeans.^2);
            s1 = size(obj.featureValueMatrix, 1);
            s2 = size(obj.featureValueMatrix, 2);
            featValMatrix = (obj.featureValueMatrix - repmat(weightedMeans, s1, 1))./repmat(weightedStd, s1, 1);
            
            for k = 1:s2
                fh = fopen(sprintf('%stestfileFeature%dClassA.dat', directoryPath, k), 'w');
                areaBelowClassAdensities = trapz(featValMatrix(:, k), obj.classAfeatureDensity(:, k));
                fprintf(fh, '%.5f %.5f\n', [featValMatrix(:, k)'; obj.classAfeatureDensity(:, k)'/areaBelowClassAdensities]);
                fclose(fh);
                fh = fopen(sprintf('%stestfileFeature%dClassB.dat', directoryPath, k), 'w');
                areaBelowClassBdensities = trapz(featValMatrix(:, k), obj.classBfeatureDensity(:, k));
                fprintf(fh, '%.5f %.5f\n', [featValMatrix(:, k)'; obj.classBfeatureDensity(:, k)'/areaBelowClassBdensities]);
                fclose(fh);
            end
        end
        function generateTikzCodeForPlotting(obj, featureNames)
            overlaps = obj.calculateFeatureOverlaps();
            for k = 1:size(overlaps, 2)
                xpos = mod(k-1, 3);
                ypos = floor((k-1) / 3);
                fprintf('%d/%d/%s/%0.1f/testfileFeature%dClassA.dat/testfileFeature%dClassB.dat,\n', ...
                    xpos, ypos, featureNames{k}, 100*overlaps(k), k, k);
            end
        end
        function obj = setClassPriors(obj, priors)
            if(sum(isnan(priors)) < 1)
                obj.classAprior = priors(1);
                obj.classBprior = priors(2);
            end
        end
    end% methods
end% classdef
