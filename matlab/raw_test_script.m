%Raw data processing script
%data = dataPreprocess_HAR_raw();

num_trial = length(data.body_acc_x);

body_acc_all = cell(num_trial,1);
total_acc_all = cell(num_trial,1);
body_proj = cell(num_trial,1);
total_proj = cell(num_trial,1);
steps = cell(num_trial,1);
for i = 1:num_trial
    body_acc_all{i} = [data.body_acc_x{i};data.body_acc_y{i};data.body_acc_z{i}];
    total_acc_all{i} = [data.total_acc_x{i};data.body_acc_y{i};data.body_acc_z{i}];
    
    [vec, lambda, Xnew, Xmean] = PCA(body_acc_all{i});
    [~,vec_idx] = max(lambda);
    vec = vec(:,vec_idx);
    Xproj = Xnew + repmat(Xmean, [1,length(Xnew)]);
    body_proj{i} = Xproj(vec_idx,:);
    
    [vec, lambda, Xnew, Xmean] = PCA(total_acc_all{i});
    [~,vec_idx] = max(lambda);
    vec = vec(:,vec_idx);
    Xproj = Xnew + repmat(Xmean, [1,length(Xnew)]);
    total_proj{i} = Xproj(vec_idx,:);
    
    cur_steps = struct('period', [], 'steps', [], 'real_len', []);
    [cur_steps.period, cur_steps.steps, cur_steps.real_len] = extract_period_gaus(body_proj{i},.5,50,.5,50,25,0);
    
    steps{i} = cur_steps;
end

%[step_vec, lambda, step_new, step_mean] = PCA(cur_steps.steps);
%label = my_kmeans(step_new(1:10,:),2);
figure
hold on
%foot1 = cur_steps.steps(:,label == 1);
%for i = 1:size(foot1,2);
for i = 1:2:size(cur_steps.steps,2);
    plot(cur_steps.steps(:,i));
end
figure
hold on
%foot2 = cur_steps.steps(:,label == 2);
%for i = 1:size(foot2,2)
for i = 2:2:size(cur_steps.steps,2)
    plot(cur_steps.steps(:,i));
end
    
    
