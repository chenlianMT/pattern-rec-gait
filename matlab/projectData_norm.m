function [data_struct] = projectData(data_struct)

num_ppl = length(data_struct.personId);
data_struct = struct('personId', {data_struct.personId}, 'data', ...
    {data_struct.data}, 'gait', {data_struct.gait}, 'eigVec', ...
    {cell(1,num_ppl)}, 'dataProj', {cell(1,num_ppl)});
for i = 1:num_ppl
    
    num_trials = length(data_struct.data{i});
    data_struct.eigVec{i} = cell(1,num_trials);
    data_struct.dataProj{i} = cell(1,num_trials);
    for j = 1:num_trials
        X = data_struct.data{i}{j}(:,50:end-50);
        X_mean = mean(X,2);
        X_mean = repmat(X_mean, [1,length(X)]);
        X = X - X_mean;
        X_mag = sqrt(sum(X.^2,1));
        X_mag = repmat(X_mag,[3,1]);
        X = X ./ X_mag;
        [vec, lambda, Xnew] = PCA(X, true);
        [~,vec_idx] = max(lambda);
        vec = vec(:,vec_idx);
        data_struct.eigVec{i}{j} = vec;
        Xproj = Xnew.*X_mag + X_mean;
        data_struct.dataProj{i}{j} = Xproj(vec_idx,:);
    end
end
        

end

