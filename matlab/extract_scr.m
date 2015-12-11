%data_raw = dataPreprocess_HAR_raw();
TEST_NUM = 1;
TEST_SAME = 3;
TEST_OTHER = 6;

test_x = data_raw.body_acc_x{TEST_NUM};
test_y = data_raw.body_acc_y{TEST_NUM};
test_z = data_raw.body_acc_z{TEST_NUM};
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
figure;
plot(proj);
title('Figure 1: 1-D Projected data')
ylabel('Acceleration (Normalized)');
xlabel('Sample');
step_len = 55;
thresh = .7;
last_val = 0;
is_step = false;
last_idx = -step_len;
steps_1 = [];
figure;
hold on
for i = 1:length(proj)
    cur_val = proj(i);
    if (cur_val > thresh && last_val < thresh)
        if(i)
            is_step = true;
            last_idx = i;
        end
    end
    if(cur_val < last_val && is_step)
        if((i+step_len-2)>length(proj))
            break;
        end
        %figure
        plot(proj(i-1:i+step_len-2));
        step = proj(i-1:i+step_len-2);
        step = step ./ sqrt(sum(step.^2));
        steps_1 = [steps_1,step'];
        is_step = false;
    end
    last_val = cur_val;
end
title('Figure 2: All threshold steps');
xlabel('Step Sample');
ylabel('Normalized acceleration');
[vecs, lambda, steps_1_proj, steps_1_mean] = PCA(steps_1, false);

label = multi_kmeans(steps_1_proj(1:5,:),3,100);

my_label = mode(label);
figure
hold on
good_steps = steps_1(:,label == my_label);

for i = 1:size(good_steps,2)
    plot(good_steps(:,i));
end
title('Figure 4: Kmeans extracted steps');
xlabel('Step Sample');
ylabel('Normalized acceleration');
figure
hold on
color = ['r';'g';'b';];
for i = 1:3
    steps = steps_1_proj(1:3,label == i);
    plot3(steps(1,:),steps(2,:),steps(3,:),['*',color(i)]);
end
title('Figure 3: Kmeans result on steps in PCA Space');


[h_OTSDF, H_OTSDF] = OTSDF(good_steps,.9);
test_x = data_raw.body_acc_x{TEST_SAME};
test_y = data_raw.body_acc_y{TEST_SAME};
test_z = data_raw.body_acc_z{TEST_SAME};
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
last_val = 0;
is_step = false;
last_idx = -step_len;
steps_2 = [];
figure;
hold on
for i = 1:length(proj)
    cur_val = proj(i);
    if (cur_val > thresh && last_val < thresh)
        if(i)
            is_step = true;
            last_idx = i;
        end
    end
    if(cur_val < last_val && is_step)
        if((i+step_len-2)>length(proj))
            break;
        end
        plot(proj(i-1:i+step_len-2));
        step = proj(i-1:i+step_len-2);
        step = step ./ sqrt(sum(step.^2));
        steps_2 = [steps_2,step'];
        is_step = false;
    end
    last_val = cur_val;
end

steps_2_proj = vecs'*steps_2;

test_x = data_raw.body_acc_x{TEST_OTHER};
test_y = data_raw.body_acc_y{TEST_OTHER};
test_z = data_raw.body_acc_z{TEST_OTHER};
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
last_val = 0;
is_step = false;
last_idx = -step_len;
steps_3 = [];
figure;
hold on
for i = 1:length(proj)
    cur_val = proj(i);
    if (cur_val > thresh && last_val < thresh)
        if(i)
            is_step = true;
            last_idx = i;
        end
    end
    if(cur_val < last_val && is_step)
        if((i+step_len-2)>length(proj))
            break;
        end
        plot(proj(i-1:i+step_len-2));
        step = proj(i-1:i+step_len-2);
        step = step ./ sqrt(sum(step.^2));
        steps_3 = [steps_3,step'];
        is_step = false;
    end
    last_val = cur_val;
end

steps_3_proj = vecs'*steps_3;
figure
hold on
plot3(steps_1_proj(1,:),steps_1_proj(2,:),steps_1_proj(3,:),'b*');
plot3(steps_2_proj(1,:),steps_2_proj(2,:),steps_2_proj(3,:),'*r');
plot3(steps_3_proj(1,:),steps_3_proj(2,:),steps_3_proj(3,:),'*g');

axis_val = [0, step_len, -.5, 1.5];
figure
hold on
for i = 1:size(steps_1,2)
    correlation_train = real(ifft(fft(steps_1(:, i)) .* conj(H_OTSDF))) * step_len;
    plot(correlation_train);
end
title('Trained Set Correlation Output');
axis(axis_val);
figure
hold on
for i = 1:size(steps_2,2)
    correlation_same = real(ifft(fft(steps_2(:, i)) .* conj(H_OTSDF))) * step_len;
    plot(correlation_same);
end
title('Figure 5: Same Person Correlation Output');
axis(axis_val);
figure
hold on
for i = 1:size(steps_3,2)
    correlation_diff = real(ifft(fft(steps_3(:, i)) .* conj(H_OTSDF))) * step_len;
    plot(correlation_diff);
end
title('Figure 6: Different Person Correlation Output');
axis(axis_val); 
    
%% Test on all
num_tests = length(data_raw.body_acc_x);
class_result = zeros(1,num_tests);
for j = 1:num_tests
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
    last_val = 0;
    is_step = false;
    last_idx = -step_len;
    steps_j = [];
    %figure;
    %hold on
    for i = 1:length(proj)
        cur_val = proj(i);
        if (cur_val > thresh && last_val < thresh)
            if(i)
                is_step = true;
                last_idx = i;
            end
        end
        if(cur_val < last_val && is_step)
            if((i+step_len-1)>length(proj))
                break;
            end
            %plot(proj(i-1:i+step_len-2));
            step = proj(i-1:i+step_len-2);
            step = step ./ sqrt(sum(step.^2));
            steps_j = [steps_j,step'];
            is_step = false;
        end
        last_val = cur_val;
    end
    correlation = zeros(size(steps_j));
    for i = 1:size(steps_j,2)
        correlation(:,i) = abs(ifft(fft(steps_j(:, i)) .* conj(H_OTSDF))) * step_len;
    end
    class_result(j) = max(max(correlation,[],1),[],2);
end
figure
bar(class_result);
title('Figure 7: Max Correlation result per trial');
xlabel('Trial Number (first 4 are the trained person)');
ylabel('Max Correlation output from the trial');