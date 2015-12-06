function [label_subject_raw, body_acc_x, body_acc_y, body_acc_z, total_acc_x, total_acc_y, total_acc_z] = dataPreprocess_HAR_raw_intermediate(dataset_select)
% dataset_select = 'train' to extract training data
% dataset_select = 'test' to extract testing data
% data_type = 'processed' to extract their processed statistics data
% data_type = 'raw' to extract the unwindowed raw data
%
% OUTPUT:
% body_acc_x is a cell array with each cell is a time series data
% label_subject labeled each row of body_acc_x

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

%% get processed data
fileID = fopen(label_subject_path, 'r');
label_subject = fscanf(fileID, '%f');
fclose(fileID);

fileID = fopen(label_activity_path, 'r');
label_activity = fscanf(fileID, '%f');
fclose(fileID);

%% get raw data
rows_for_walking = find(label_activity == 1);
index_subject = unique(label_subject);
label_subject_raw = [];
body_acc_x = {};
body_acc_y = {};
body_acc_z = {};
total_acc_x = {};
total_acc_y = {};
total_acc_z = {};
for i = 1:length(index_subject),
	current_subject = index_subject(i);
	rows_for_subject = find(label_subject == current_subject);
	rows_for_subject_walking = intersect(rows_for_subject, rows_for_walking);

	% open file
	fileID = fopen(body_acc_x_path, 'r');
	b_x = fscanf(fileID, '%f');
	fclose(fileID);
	fileID = fopen(body_acc_y_path, 'r');
	b_y = fscanf(fileID, '%f');
	fclose(fileID);
	fileID = fopen(body_acc_z_path, 'r');
	b_z = fscanf(fileID, '%f');
	fclose(fileID);
	fileID = fopen(total_acc_x_path, 'r');
	t_x = fscanf(fileID, '%f');
	fclose(fileID);
	fileID = fopen(total_acc_y_path, 'r');
	t_y = fscanf(fileID, '%f');
	fclose(fileID);
	fileID = fopen(total_acc_z_path, 'r');
	t_z = fscanf(fileID, '%f');
	fclose(fileID);
        
    % load data
	window_size = 128;
	hop_size = window_size/2;
	b_x = buffer(b_x, window_size, 0, 'nodelay');
	b_x = b_x';
    b_x = b_x(rows_for_subject_walking, :);
    b_y = buffer(b_y, window_size, 0, 'nodelay');
	b_y = b_y';
    b_y = b_y(rows_for_subject_walking, :);
    b_z = buffer(b_z, window_size, 0, 'nodelay');
	b_z = b_z';
    b_z = b_z(rows_for_subject_walking, :);
    t_x = buffer(t_x, window_size, 0, 'nodelay');
	t_x = t_x';
    t_x = t_x(rows_for_subject_walking, :);
    t_y = buffer(t_y, window_size, 0, 'nodelay');
	t_y = t_y';
    t_y = t_y(rows_for_subject_walking, :);
    t_z = buffer(t_z, window_size, 0, 'nodelay');
	t_z = t_z';
    t_z = t_z(rows_for_subject_walking, :);
    
    % init for firt run on each subject
    label_subject_raw = [label_subject_raw; current_subject];
    body_acc_x{length(body_acc_x) + 1} = b_x(1, 1:hop_size);
    body_acc_y{length(body_acc_y) + 1} = b_y(1, 1:hop_size);
    body_acc_z{length(body_acc_z) + 1} = b_z(1, 1:hop_size);
    total_acc_x{length(total_acc_x) + 1} = t_x(1, 1:hop_size);
    total_acc_y{length(total_acc_y) + 1} = t_y(1, 1:hop_size);
    total_acc_z{length(total_acc_z) + 1} = t_z(1, 1:hop_size);

    for j = 2:size(b_x, 1),
        if b_x(j, 1:hop_size) ~= b_x(j - 1, hop_size + 1:end);
            body_acc_x{end} = [body_acc_x{end}, b_x(j - 1, hop_size + 1: end)];
            body_acc_x{length(body_acc_x) + 1} = b_x(j, 1:hop_size);
            
            body_acc_y{end} = [body_acc_y{end}, b_y(j - 1, hop_size + 1: end)];
            body_acc_y{length(body_acc_y) + 1} = b_y(j, 1:hop_size);
            
            body_acc_z{end} = [body_acc_z{end}, b_z(j - 1, hop_size + 1: end)];
            body_acc_z{length(body_acc_z) + 1} = b_z(j, 1:hop_size);
            
            total_acc_x{end} = [total_acc_x{end}, t_x(j - 1, hop_size + 1: end)];
            total_acc_x{length(total_acc_x) + 1} = t_x(j, 1:hop_size);
            
            total_acc_y{end} = [total_acc_y{end}, t_y(j - 1, hop_size + 1: end)];
            total_acc_y{length(total_acc_y) + 1} = t_y(j, 1:hop_size);
            
            total_acc_z{end} = [total_acc_z{end}, t_z(j - 1, hop_size + 1: end)];
            total_acc_z{length(total_acc_z) + 1} = t_z(j, 1:hop_size);
            
            label_subject_raw = [label_subject_raw; current_subject];
        else,
            body_acc_x{end} = [body_acc_x{end}, b_x(j, 1:hop_size)];
            body_acc_y{end} = [body_acc_y{end}, b_y(j, 1:hop_size)];
            body_acc_z{end} = [body_acc_z{end}, b_z(j, 1:hop_size)];
            total_acc_x{end} = [total_acc_x{end}, t_x(j, 1:hop_size)];
            total_acc_y{end} = [total_acc_y{end}, t_y(j, 1:hop_size)];
            total_acc_z{end} = [total_acc_z{end}, t_z(j, 1:hop_size)];
        end
    end
    body_acc_x{end} = [body_acc_x{end}, b_x(end, hop_size + 1:end)];
    body_acc_y{end} = [body_acc_y{end}, b_x(end, hop_size + 1:end)];
    body_acc_z{end} = [body_acc_z{end}, b_x(end, hop_size + 1:end)];
    total_acc_x{end} = [total_acc_x{end}, t_x(end, hop_size + 1:end)];
    total_acc_y{end} = [total_acc_y{end}, t_y(end, hop_size + 1:end)];
    total_acc_z{end} = [total_acc_z{end}, t_z(end, hop_size + 1:end)];
end