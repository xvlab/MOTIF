clear;clc;
img = imread('mask.jpg');
mask = rgb2gray(img);
for i = 1:size(mask, 1); for j = 1:size(mask, 2); if mask(i, j) == 255; mask(i, j) = 0; end; end; end
for i = 1:size(mask, 1); for j = 1:size(mask, 2); if mask(i, j) > 240; mask(i, j) = 0; end; end; end
black_mask = zeros(size(img, 1), size(img, 2));
for i = 1:size(mask, 1); for j = 1:size(mask, 2); if mask(i, j) ~= 0; black_mask(i, j) = 255; end; end; end
for i = 2:size(mask, 1) - 1; for j = 2:size(mask, 2) - 1; if black_mask(i, j) == 0 && black_mask(i - 1, j) + black_mask(i, j - 1) + black_mask(i + 1, j) + black_mask(i, j + 1) >= 255 * 3; black_mask(i, j) = 255; end; end; end
black_mask=[zeros((1000-size(black_mask,1))/2,size(black_mask,1)) ;black_mask ;  zeros((1000-size(black_mask,1))/2,size(black_mask,1))];
black_mask=[zeros(1000,(1000-size(black_mask,2))/2) black_mask   zeros(1000,(1000-size(black_mask,2))/2)];
imshow(black_mask);
[I1, D, L] = sift(black_mask);

showkeys(I1, L);
% save('black_mask','black_mask');