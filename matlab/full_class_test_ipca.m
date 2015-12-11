%data_raw = dataPreprocess_HAR_raw();
num_trial = length(data_raw.label_subject_raw);
step_len = 55;
thresh  = .7;
num_eigs = 4;
num_thresh = 4;
class_thresh_perc = [1.05,1.1,1.15,1.2];
true_pos_vec = zeros(1,num_thresh);
true_neg_vec = zeros(1,num_thresh);
false_pos_vec = zeros(1,num_thresh);
false_neg_vec = zeros(1,num_thresh);
class_result = zeros(num_trial,1);
for m = 1:num_thresh
    false_pos = 0;
    false_neg = 0;
    true_pos = 0;
    true_neg = 0;
    for i = 1:num_trial
        test_x = data_raw.body_acc_x{i};
        test_y = data_raw.body_acc_y{i};
        test_z = data_raw.body_acc_z{i};
        test_all = [test_x;test_y;test_z];

        [~,~,proj,~] = PCA(test_all,false);
        proj = proj(1,:);
        min_val = min(proj);
        proj = proj - min_val;
        max_val = max(proj);
        proj = proj ./ max_val;
        mean_val = mean(proj);
        if(mean_val > .5)
            proj = -proj + 1;
        end

        good_steps = extract_steps(proj,thresh,step_len);
        num_steps = size(good_steps,2);
        [vecs,lambda,~,mean_vec] = PCA(good_steps,false);
        
        if(num_steps < num_eigs)
            vecs = vecs(:,1:num_steps);
        else
            vecs = vecs(:,1:num_eigs);
        end
        
        mean_rep = repmat(mean_vec,[1,size(good_steps,2)]);
        proj = vecs'*(good_steps - mean_rep);
        reconstruct = (vecs*proj) + mean_rep;
        err_vec = good_steps - reconstruct;
        dist_vec = sqrt(sum(err_vec.^2,1));
        cur_thresh = max(dist_vec) * class_thresh_pec(m);
        

        ground_truth = data_raw.label_subject_raw == data_raw.label_subject_raw(i);
        ground_truth = logical([ground_truth(1:i-1);ground_truth(i+1:end)]);
        for j = 1:num_trial
            if i == j
                continue;
            end
            test_x = data_raw.body_acc_x{j};
            test_y = data_raw.body_acc_y{j};
            test_z = data_raw.body_acc_z{j};
            test_all = [test_x;test_y;test_z];

            [~,~,proj,~] = PCA(test_all,false);
            proj = proj(1,:);
            min_val = min(proj);
            proj = proj - min_val;
            max_val = max(proj);
            proj = proj ./ max_val;
            mean_val = mean(proj);
            if(mean_val > .5)
                proj = -proj + 1;
            end
            test_steps = extract_steps(proj,thresh,step_len);
            mean_rep = repmat(mean_vec,[1,size(test_steps,2)]);
            test_steps_cent = test_steps - mean_rep;
            test_steps_proj = vecs'*test_steps_cent;
            test_steps_recon = vecs*test_steps_proj;
            test_steps_recon = test_steps_recon + mean_rep;
            err_vec = test_steps-test_steps_recon;
            dist = sqrt(sum(err_vec.^2,1));
            correlation = zeros(size(test_steps));
            class_result(j) = min(dist);
        end
        is_train = (class_result < cur_thresh);
        is_train = logical([is_train(1:(i-1));is_train((i+1):end)]);
        true_pos = true_pos + sum(is_train & ground_truth);
        true_neg = true_neg + sum(~is_train & ~ground_truth);
        false_neg = false_neg + sum(~is_train & ground_truth);
        false_pos = false_pos + sum(is_train & ~ground_truth);
    end
    false_neg_vec(m) = false_neg / (false_neg + true_pos);
    false_pos_vec(m) = false_pos / (false_pos + true_neg);
    true_neg_vec(m) = true_neg / (true_neg + false_pos);
    true_pos_vec(m) = true_pos / (true_pos + false_neg);
end
    
    
        
        
        