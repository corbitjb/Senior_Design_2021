function [filteredimage] = LNRfilter(inputimage)

% A = imread('Capturetest3.jpg');
% figure
% imshow(A);
% title('Unfiltered Image');
% img = double(A);
% load('finalimageDOUBLE.mat');
% img = intensity/max(max(intensity));
% img = flipud(img);
img = inputimage;
% imshow(img/255);
var_n = 100;
B = zeros(size(img));
C = zeros(size(img));
S = size(B);
max_M = 7;
threshold = 20;
figure

for k1 = 1:S(1)
    for k2 = 1:S(2)
        M = 3;
        test_image = img(max(k1-M,1):min(k1+M,S(1)),max(k2-M,1):min(k2+M,S(2)));
        g = img(k1,k2);
        m_l = mean(test_image(:));
        var_l = var(test_image(:));
        C(k1,k2) = g - ((var_n/var_l)*(g - m_l));
        
%         if (var_n = 0)
%             C(k1,k2) = g;
    end
end

filteredimage = C;