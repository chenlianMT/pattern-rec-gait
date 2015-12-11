function [label, J] = my_kmeans(data, K)
%K_MEAN_CLUSTER
%Data NxD
%K is number of clusters

%output
%label
[num_data,num_dim] = size(data); 
rnk = zeros(num_data,K);
%indices = ceil(rand(num_data,1)*K);
%real_idx = sub2ind(size(rnk),1:num_data,indices');
%rnk(real_idx) = ones(1,num_data);

%rt = rnk';
%num_per_cluster = sum(rt,2);
%tot = rt*data;
idx = ceil(rand(K,1)*num_data);
idx = sort(idx);
while(sum(~diff(idx)))
    idx = ceil(rand(K,1)*num_data);
    idx = sort(idx);
end
%uk = tot./repmat(num_per_cluster,[1 num_dim]);
uk = data(idx,:);
delta = 1; count = 0;
J = sum(sum((data-rnk*uk).^2,2),1);
while delta,
    count = count + 1;
    rnk = findClosestMean(data,uk);
    rt = rnk';
    num_per_cluster = sum(rt,2);
    if(sum(~(num_per_cluster)))
        idx = find(num_per_cluster == 0);
        uk(idx,:) = findFurthestPoint(data,uk,idx);
        continue
    end
    tot = rt*data;
    uk = tot./repmat(num_per_cluster,[1 num_dim]);
    J_old = J;
    J = sum(sum((data-rnk*uk).^2,2),1);
    delta = (J_old - J);
end
[~,label] = max(rnk,[],2);
end
function [ r ] = findClosestMean( Data, uk )
%Data NxD
%uk KxD
%r NxK

%initilize variables
[N, D] = size(Data);
K = size(uk,1);
distance = zeros(N,K);

for i = 1:K
    %get a mat that holds the vector from each point to the ith prototype
    curr_u = uk(i,:);
    curr_u_mat = repmat(curr_u, [N,1]);
    diff_vec = Data - curr_u_mat;
    %calculate the distance of all data points from the ith cluster
    distance(:,i) = sum(diff_vec .^ 2, 2);
end
%asiagn each datapoint to the cluster its closest to
r = (distance == repmat(min(distance,[],2), [1, K]));
end
function [val] = findFurthestPoint(Data, uk, empt_u)
k = size(uk,1);
N = size(Data,1);
cur_dist = [];
for i = 1:k
    if(i == empt_u)
        continue;
    end
    curr_u = uk(i,:);
    curr_u_mat = repmat(curr_u, [N,1]);
    diff_vec = Data - curr_u_mat;
    %calculate the distance of all data points from the ith cluster
    cur_dist = [cur_dist,sum(diff_vec .^ 2, 2)];
    cur_dist = min(cur_dist,[],2);
end
[~,idx] = sort(cur_dist,1,'descend');
val = Data(idx(1),:);
end
    