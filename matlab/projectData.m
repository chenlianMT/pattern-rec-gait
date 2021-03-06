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
        [vec, lambda, Xnew, Xmean] = PCA(data_struct.data{i}{j}(:,50:end-50));
        [~,vec_idx] = max(lambda);
        vec = vec(:,vec_idx);
        data_struct.eigVec{i}{j} = vec;
        Xproj = Xnew + repmat(Xmean, [1,length(Xnew)]);
        data_struct.dataProj{i}{j} = Xproj(vec_idx,:);
    end
end
        

end

