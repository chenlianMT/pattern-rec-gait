function [label_activity, label_subject, features_561, body_acc_x, body_acc_y, body_acc_z, total_acc_x, total_acc_y, total_acc_z] = dataPreprocess_HAR(dataset_select)
% dataset_select = 'train' to extract training data
% dataset_select = 'test' to extract testing data

%% data path
datasetpath = '../../DATA/UCI HAR Dataset/';
datapath = [datasetpath dataset_select '/'];
label_subject_path = [datapath 'subject_' dataset_select '.txt'];
label_activity_path = [datapath 'y_' dataset_select '.txt'];
features_561_path = [datapath 'X_' dataset_select '.txt'];
body_acc_x_path = [datapath 'Inertial Signals/body_acc_x_' dataset_select '.txt'];
body_acc_y_path = [datapath 'Inertial Signals/body_acc_y_' dataset_select '.txt'];
body_acc_z_path = [datapath 'Inertial Signals/body_acc_z_' dataset_select '.txt'];
total_acc_x_path = [datapath 'Inertial Signals/total_acc_x_' dataset_select '.txt'];
total_acc_y_path = [datapath 'Inertial Signals/total_acc_y_' dataset_select '.txt'];
total_acc_z_path = [datapath 'Inertial Signals/total_acc_z_' dataset_select '.txt'];

path_cells = cell(9, 1);
path_cells{1} = label_subject_path;
path_cells{2} = label_activity_path;
path_cells{3} = features_561_path;
path_cells{4} = body_acc_x_path;
path_cells{5} = body_acc_y_path;
path_cells{6} = body_acc_z_path;
path_cells{7} = total_acc_x_path;
path_cells{8} = total_acc_y_path;
path_cells{9} = total_acc_z_path;


%% get label
fileID = fopen(label_subject_path, 'r');
label_subject = fscanf(fileID, '%f');
fclose(fileID);

fileID = fopen(label_activity_path, 'r');
label_activity = fscanf(fileID, '%f');
fclose(fileID);

fileID = fopen(features_561_path, 'r');
features_561 = fscanf(fileID, '%f');
features_561 = buffer(features_561, 561, 0, 'nodelay');
features_561 = features_561';
fclose(fileID);

%% unwindow stuff
% still writing...