%data_raw = dataPreprocess_HAR_raw();
num_trial = length(data_raw.label_subject_raw);
step_len = 55;
thresh  = .7;
class_thresh = [.9,1,1.1,1.2,1.3];
true_pos_vec = zeros(1,4);
true_neg_vec = zeros(1,4);
false_pos_vec = zeros(1,4);
false_neg_vec = zeros(1,4);
class_result = zeros(num_trial,1);
for m = 1:4
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
        [h_OTSDF, H_OTSDF] = mace(good_steps);

        ground_truth = data_raw.label_subject_raw == i;
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
            correlation = zeros(size(steps_j));
            for k = 1:size(test_steps,2)
                correlation(:,k) = abs(ifft(fft(test_steps(:, k)) .* conj(H_OTSDF))) * step_len;
            end
            class_result(j) = max(max(correlation,[],1),[],2);
            is_train = (class_result > class_thresh(m));
            is_train = logical([is_train(1:(i-1));is_train((i+1):end)]);
            true_pos = true_pos + sum(is_train & ground_truth);
            true_neg = true_neg + sum(~is_train & ~ground_truth);
            false_neg = false_neg + sum(~is_train & ground_truth);
            false_pos = false_pos + sum(is_train & ~ground_truth);
        end
    end
    false_neg_vec(m) = false_neg / (false_neg + true_pos);
    false_pos_vec(m) = false_pos / (false_pos + true_neg);
    true_neg_vec(m) = true_neg / (true_neg + false_pos);
    true_pos_vec(m) = true_pos / (true_pos + false_neg);
end
    
    
        
        
        