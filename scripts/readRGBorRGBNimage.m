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