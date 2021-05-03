function intensity = adaptiveFilter(intensity,T)
% this function filters the image by first performing a blanket threshold
% and then an adaptive threshold around the remaining parts of the image
% "intensity" is the image that will be filtered
% "" is the threshold for the blanket threshold that will be applied
% uniformly across the entire image

s = size(intensity);
intensity = intensity./(max(max(intensity))); % normalize intensity matrix
maximum = max(max(intensity)); % find new maximum for filtering

%% blanket threshold first
threshold_value = T*maximum;
for i = 1:s(1)
    for j = 1:s(2)
        if(intensity(i,j) < threshold_value)
            intensity(i,j) = 0; % set values less than threshold value to 0
        end
    end
end
%% adaptive thresholding
threshold = adaptthresh(intensity,0.05,'Statistic','gaussian'); % find adaptive threshold value
intensity = imbinarize(intensity,threshold);  % compute new image
end