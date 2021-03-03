s = size(A);
figure
pcolor(A); shading flat; grid off;
title('Original Image');

%Use medfilt2 fo regular median filter
B = medfilt2(A);
figure;
pcolor(B); shading flat; grid off;
title('3x3 regular median filt');

C = B;
s1 = size(C);
for i = 1:s1(1)
    for j = 1:s1(2)
        %Normalize C by dividing by the highest intensity value.
        %max(max(C))...
        %The more stops and greater bandwidth, the higher the threshold needed to elimante rings
        if(C(i,j) < 50000)
            C(i,j) = 0;
        end
    end
end
figure;
pcolor(C); shading flat; grid off;
title('3x3 regular median filt + threshold');%Apply Threshold to 3x3 median filtered image

% B1 = medfilt2(A, [13, 13]);
% figure
% pcolor(B1); shading flat; grid off;
% title('13x13 regular median filt');

%Adaptive Median filter
for k1 = 1:s(1)
    for k2 = 1:s(2)
        stage_A = 1;
        stage_B = 0;
        M = 1;
        threshold = 1000;% Test different thresholds
        max_M = 13;
        while stage_A == 1
            test_image = A(max(k1-M,1):min(k1+M,s(1)),max(k2-M,1):min(k2+M,s(2)));
            A1 = median(test_image(:))-min(test_image(:));
            A2 = median(test_image(:))-max(test_image(:));
            if(A1 > threshold) && (A2<(-1*threshold))
                stage_A = 0;
                stage_B = 1;
            elseif M<= max_M
                    M = M+1;
            else
                B3(k1,k2) = median(test_image(:));
                stage_A = 0;
            end
        end
        if stage_B == 1
            B3(k1,k2) = median(test_image(:));
        end
    end
end
figure
pcolor(B3); shading flat; grid off;
title('Adaptive median filter');

C1 = B3;
s1 = size(C1);
for i = 1:s1(1)
    for j = 1:s1(2)
        %The more stops and greater bandwidth, the higher the threshold needed to elimante rings
        if(C1(i,j) < 50000)
            C1(i,j) = 0;
        end
    end
end
figure;
pcolor(C1); shading flat; grid off;
title('3x3 regular median filt + threshold');%Apply Threshold to 3x3 median filtered image