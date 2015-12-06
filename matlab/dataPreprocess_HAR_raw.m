function [label_subject_raw, body_acc_x, body_acc_y, body_acc_z, total_acc_x, total_acc_y, total_acc_z] = dataPreprocess_HAR_raw()

[label_subject_raw_test, body_acc_x_test, body_acc_y_test, body_acc_z_test, total_acc_x_test, total_acc_y_test, total_acc_z_test] = dataPreprocess_HAR_raw_intermediate('test');
[label_subject_raw_train, body_acc_x_train, body_acc_y_train, body_acc_z_train, total_acc_x_train, total_acc_y_train, total_acc_z_train] = dataPreprocess_HAR_raw_intermediate('train');

label_subject_raw = [label_subject_raw_test; label_subject_raw_train];
body_acc_x = {};
body_acc_y = {};
body_acc_z = {};
total_acc_x = {};
total_acc_y = {};
total_acc_z = {};
for i = 1:length(body_acc_x_test),
    body_acc_x{length(body_acc_x) + 1} = body_acc_x_test{i};
    body_acc_y{length(body_acc_y) + 1} = body_acc_y_test{i};
    body_acc_z{length(body_acc_z) + 1} = body_acc_z_test{i};
    total_acc_x{length(total_acc_x) + 1} = total_acc_x_test{i};
    total_acc_y{length(total_acc_y) + 1} = total_acc_y_test{i};
    total_acc_z{length(total_acc_z) + 1} = total_acc_z_test{i};
end
for i = 1:length(body_acc_x_train),
    body_acc_x{length(body_acc_x) + 1} = body_acc_x_train{i};
    body_acc_y{length(body_acc_y) + 1} = body_acc_y_train{i};
    body_acc_z{length(body_acc_z) + 1} = body_acc_z_train{i};
    total_acc_x{length(total_acc_x) + 1} = total_acc_x_train{i};
    total_acc_y{length(total_acc_y) + 1} = total_acc_y_train{i};
    total_acc_z{length(total_acc_z) + 1} = total_acc_z_train{i};
end