function filtered_image = joel_filters(A,threshold)
% This function calls all of the filters in the order I think is best
% A is the matrix that will be filtered
% threshold is a value between 0 and 1 that will determine how to apply
% a blanket threshold

s = size(A);
A = lnrfilt(A);
maximum = max(max(A));
threshold_value = threshold*maximum;
for i = 1:s(1)
    for j = 1:s(2)
        if(A(i,j) < threshold_value)
            A(i,j) = 0;
        end
    end
end
% 
% A = medfilt2(A);
% A = spatial_filter(A);
filtered_image = A;

%% The section below explores frequecy domain filtering???
end