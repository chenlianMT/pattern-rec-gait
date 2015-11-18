function [ vecs, lambdas ] = LDA(X, num_classes, labels)
%LDA

[dims, num_points] = size(X);

mean_mats = zeros(dims,num_classes);
tot_mean = zeros(dims,1);
num_per_class = zeros(1,num_classes);
for i = 1: num_points
    cur_class = labels(i);
    mean_mats(:,cur_class) = mean_mats(:,cur_class) + X(:,i);
    tot_mean = tot_mean + X(:,i);
    num_per_class(cur_class) = num_per_class(cur_class) + 1;
end

num_per_class_mat = repmat(num_per_class, [dims,1]);
mean_mats = mean_mats ./ num_per_class_mat;
tot_mean = tot_mean ./ num_points;

Sb = zeros(dim);
for i = 1:num_classes
    class_dist = mean_mats(:,i) - tot_mean;
    Sb = Sb + num_per_class(i).*(class_dist*class_dist');
end
Sw = zeros(dim);
for i = 1:num_classes
    cur_mean_mat = repmat(mean_mats(:,i), [1,num_per_class(i)]);
    x_min_mean = X(:,labels == i) - cur_mean_mat;
    Sw = Sw + x_min_mean*x_min_mean';
end

E = Sw\Sb;
[vecs, lambdas] = eig(E);


end

