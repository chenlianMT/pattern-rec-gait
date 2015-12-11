function [labels] = multi_kmeans(data, k, num_attempts)
J = -1;
n = size(data,2);
labels = ones(n,1);
for i = 1:num_attempts
    [temp_label,temp_j] = my_kmeans(data',k);
    if((J < 0) || (temp_j < J))
        labels = temp_label;
        J = temp_j;
    end
end

end

