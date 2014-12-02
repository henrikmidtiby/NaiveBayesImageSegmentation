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
function [featureMatrix, bandwidths, featureNames] = calculateColourFeatures(img, selectedFeatures)
% calculateColourFeatures Calculates the color features used as input for the classifier
%       calculateColourFeatures(img, selectedFeatures) calculates the color 
%       features for the classifier using the image supplied in img using the
%       features selected by index in selectedFeatures.
%       If you wish to add new color features this is the only file you need to
%       edit besides adding your new feature to the selectedFeatures vector

% Define bandwidths
scale = 1;
bandwidths = [10/scale, 150/scale, 5/scale, ... %R, G, B
    0.01, 0.005, 150/scale, ... % H, S, V
    100/scale, 150/scale, 0.02, ... % ExG, ToRef, Ratio
    0.005, 0.00005, 0.0001, 0.0002, ... % gNDVI, r, g, b
    0.2/scale, 0.005, 500/scale, 0.005, 30/scale]; %ExR, n, N, NDVI, ExGN

drgb = single(img(:, :, 1:3));
dhsv = double(rgb2hsv(img(:, :, 1:3)));
%dhsv = drgb;
% Extract colour values
R = drgb(:, :, 1);
G = drgb(:, :, 2);
B = drgb(:, :, 3);

H = dhsv(:, :, 1);
S = dhsv(:, :, 2);
V = dhsv(:, :, 3);

% Convert to list form
R = R(:);
G = G(:);
B = B(:);
H = H(:);
S = S(:);
V = V(:);

% Calculate derivative features.
eg = 2*G - R - B;

er = 1.4*R-G;

rr = 90;
rg = 112;
rb = 72;
toref = sqrt((R - rr).^2 + (G - rg).^2 + (B - rb).^2);

ratio = G./(R.^0.6.*B.^0.4 + 0.01);
id = ratio > 7;
ratio(id) = 7;

% Calculate gNDVI and ensure that NAN do not occur.
gNDVI = (G - R)./(G + R + 0.00000001);

% Calculate intensity for nomalization
intensity = R + G + B + 0.00000001;
r = R ./ intensity;
g = G ./ intensity;
b = B ./ intensity;


% Arrange features in a feature matrix
featureMatrix = [R, G, B, H, S, V, eg, toref, ratio, gNDVI, r, g, b, er];


if(size(img, 3) == 4)
    % Nir is present
    N = double(img(:, :, 4))*0.5318;
    N = N(:);
    ndvi = (N - R) ./ (N + R + 0.00000001);

    egn = N+G-R-B;
    
    
    % Change in definition of chromacities
    intensity = intensity + N;
%    r = R ./ intensity;
%    g = G ./ intensity;
%    b = B ./ intensity;
    n = N ./ intensity;
    featureMatrix = [R, G, B, H, S, V, eg, toref, ratio, gNDVI, r, g, b, er, n, N, ndvi, egn];
end


% Define feature names
featureNames = cell(18, 1);
%[1, 2, 3, 16, 17, 7, 14, 11, 12, 13, 15, 18];
featureNames{1} = 'R';
featureNames{2} = 'G';
featureNames{3} = 'B';
featureNames{4} = 'H';
featureNames{5} = 'S';
featureNames{6} = 'V';
featureNames{7} = 'ExG';
featureNames{8} = 'ToRef';
featureNames{9} = 'Ratio';
featureNames{10} = 'gNDVI';
featureNames{11} = 'r';
featureNames{12} = 'g';
featureNames{13} = 'b';
featureNames{14} = 'ExR';
featureNames{15} = 'n';
featureNames{16} = 'N';
featureNames{17} = 'NDVI';
featureNames{18} = 'ExGN';



if(nargin == 2)
    % Only use the selected features
    featureMatrix = featureMatrix(:, selectedFeatures);
    bandwidths = bandwidths(selectedFeatures);
    featureNames = featureNames(selectedFeatures);
end

    
end