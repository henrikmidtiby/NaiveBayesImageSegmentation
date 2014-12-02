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
function [img] = readRGBorRGBNimage(filename)

[img, ~, alpha] = imread(filename);

% Todo merge img and alpha if suitable
s1 = size(img, 1);
s2 = size(img, 2);
if(size(alpha, 1) == s1 && size(alpha, 2) == s2)
    % Merge img and alpha
    newimg = zeros(s1, s2, 4);
    newimg(:, :, 1:3) = img;
    newimg(:, :, 4) = alpha;
    img = newimg;
end

end
