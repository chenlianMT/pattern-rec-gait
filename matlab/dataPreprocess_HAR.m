function [training, testing] = dataPreprocess_HAR(percent_test)
% dataset_select = 'train' to extract training data
% dataset_select = 'test' to extract testing data
training = struct('label_activity',[],'label_subject',[],'features_561',...
    [],'body_acc_x', [], 'body_acc_y',[], 'body_acc_z', [], ...
    'total_acc_x', [], 'total_acc_y', [], 'total_acc_z', []);
testing = training;

%% data path
datasetpath = '../../DATA/UCI HAR Dataset/';
dataset_select = 'train';
datapath = [datasetpath dataset_select '/'];

label_subject_path_train = [datapath 'subject_' dataset_select '.txt'];
label_activity_path_train = [datapath 'y_' dataset_select '.txt'];
features_561_path_train = [datapath 'X_' dataset_select '.txt'];
body_acc_x_path_train = [datapath 'Inertial Signals/body_acc_x_' dataset_select '.txt'];
body_acc_y_path_train = [datapath 'Inertial Signals/body_acc_y_' dataset_select '.txt'];
body_acc_z_path_train = [datapath 'Inertial Signals/body_acc_z_' dataset_select '.txt'];
total_acc_x_path_train = [datapath 'Inertial Signals/total_acc_x_' dataset_select '.txt'];
total_acc_y_path_train = [datapath 'Inertial Signals/total_acc_y_' dataset_select '.txt'];
total_acc_z_path_train = [datapath 'Inertial Signals/total_acc_z_' dataset_select '.txt'];

dataset_select = 'test';
datapath = [datasetpath dataset_select '/'];
label_subject_path_test = [datapath 'subject_' dataset_select '.txt'];
label_activity_path_test = [datapath 'y_' dataset_select '.txt'];
features_561_path_test = [datapath 'X_' dataset_select '.txt'];
body_acc_x_path_test = [datapath 'Inertial Signals/body_acc_x_' dataset_select '.txt'];
body_acc_y_path_test = [datapath 'Inertial Signals/body_acc_y_' dataset_select '.txt'];
body_acc_z_path_test = [datapath 'Inertial Signals/body_acc_z_' dataset_select '.txt'];
total_acc_x_path_test = [datapath 'Inertial Signals/total_acc_x_' dataset_select '.txt'];
total_acc_y_path_test = [datapath 'Inertial Signals/total_acc_y_' dataset_select '.txt'];
total_acc_z_path_test = [datapath 'Inertial Signals/total_acc_z_' dataset_select '.txt'];
path_cells = cell(18, 1);
path_cells{1} = label_subject_path_train;
path_cells{2} = label_activity_path_train;
path_cells{3} = features_561_path_train;
path_cells{4} = body_acc_x_path_train;
path_cells{5} = body_acc_y_path_train;
path_cells{6} = body_acc_z_path_train;
path_cells{7} = total_acc_x_path_train;
path_cells{8} = total_acc_y_path_train;
path_cells{9} = total_acc_z_path_train;
path_cells{10} = label_subject_path_test;
path_cells{11} = label_activity_path_test;
path_cells{12} = features_561_path_test;
path_cells{13} = body_acc_x_path_test;
path_cells{14} = body_acc_y_path_test;
path_cells{15} = body_acc_z_path_test;
path_cells{16} = total_acc_x_path_test;
path_cells{17} = total_acc_y_path_test;
path_cells{18} = total_acc_z_path_test;

%% get label
fileID = fopen(label_subject_path_train, 'r');
label_subject_train = fscanf(fileID, '%f');
fclose(fileID);

fileID = fopen(label_subject_path_test, 'r');
label_subject_test = fscanf(fileID, '%f');
fclose(fileID);

label_subject = [label_subject_train;label_subject_test];
num_subj = max(label_subject);
test_idx = cell(num_subj,1);
train_idx = cell(num_subj,1);
test_label = [];
train_label = [];
for i = 1:num_subj
    cur_idxs = find(label_subject == i);
    num_test = round((percent_test/100) * length(cur_idxs));
    num_train = length(cur_idxs) - num_test;
    train_idx{i} = cur_idxs(1:num_train);
    test_idx{i} = cur_idxs(num_train+1:end);
    test_label = [test_label;label_subject(test_idx{i})];
    train_label = [train_label;label_subject(train_idx{i})];
end
training.label_subject = train_label;
testing.label_subject = test_label;

fileID = fopen(label_activity_path_test, 'r');
label_activity_test = fscanf(fileID, '%f');
fclose(fileID);

fileID = fopen(label_activity_path_train, 'r');
label_activity_train = fscanf(fileID, '%f');
fclose(fileID);

label_activity = [label_activity_test;label_activity_train];
test_activity = [];
train_activity = [];
for i = 1:num_subj
    test_activity = [test_activity;label_activity(test_idx{i})];
    train_activity = [train_activity;label_activity(train_idx{i})];
end
training.label_activity = train_activity;
testing.label_activity = test_activity;

fileID = fopen(features_561_path_test, 'r');
features_561 = fscanf(fileID, '%f');
features_561 = buffer(features_561, 561, 0, 'nodelay');
features_561_test = features_561';
fclose(fileID);

fileID = fopen(features_561_path_train, 'r');
features_561 = fscanf(fileID, '%f');
features_561 = buffer(features_561, 561, 0, 'nodelay');
features_561_train = features_561';
fclose(fileID);

features_561 = [features_561_test;features_561_train];

test_feat = [];
train_feat = [];
for i = 1:num_subj
    test_feat = [test_feat;features_561(test_idx{i},:)];
    train_feat = [train_feat;features_561(train_idx{i},:)];
end
training.features_561 = train_feat;
testing.features_561 = test_feat;

%% unwindow stuff
% still writing...