function run_verification_OTSDF(raw_data, alpha, threshold)

% raw_data = dataPreprocess_HAR_raw();

% figure out the start and end for 15 steps of subject 2
first_2 = [82 137 192 250 310 369 425 481 537 601 662 719 775 830 890];
last_2 = [136 191 249 309 368 424 480 536 600 661 718 774 829 889 942];

subject = 2; % train a OTSDF classifier using subject 2
% xyz = 'xyz'; % 3d
xyz = ''; % 1d
[H_OTSDF, step_len] = train_OTSDF(raw_data, first_2, last_2, alpha, subject, 1, xyz);

% compute correlation
% training experiment
subject = 2;
index = 1;
training_score = verify_OTSDF(raw_data, subject, step_len, H_OTSDF, index, xyz);

index = 2;
same_score = verify_OTSDF(raw_data, subject, step_len, H_OTSDF, index, xyz);
same_score = [same_score, verify_OTSDF(raw_data, subject, step_len, H_OTSDF, 3, xyz), verify_OTSDF(raw_data, subject, step_len, H_OTSDF, 4, xyz);];

all_subject = unique(raw_data.label_subject_raw);
diff_score = [];
for subject = all_subject(:)'
    if subject == 2,
        continue,
    end
    for index = 1:4,
        temp = verify_OTSDF(raw_data, subject, step_len, H_OTSDF, index, xyz);
        diff_score = [diff_score, temp];
    end
end

% plot
figure
    bar([training_score, same_score, diff_score]);
    title(sprintf('Correlation output of OTSDF filter alpha = %.2f', alpha));

TP = length(find(same_score > threshold))/(length(find(same_score > threshold)) + length(find(same_score < threshold)));
FP = length(find(diff_score > threshold))/(length(find(diff_score > threshold)) + length(find(diff_score < threshold)));
TN = length(find(diff_score < threshold))/(length(find(diff_score > threshold)) + length(find(diff_score < threshold)));
FN = 1 - TP;
fprintf('True Positive: %.2f', TP);
disp('\n')
fprintf('False Positive: %.2f', FP);
disp('\n')
fprintf('True Negative: %.2f', TN);
disp('\n')
fprintf('False Negative: %.2f', FN);
disp('\n')