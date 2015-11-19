function data_struct = dataPreprocess(dataset_path, filter_flag, fs, dataset_name, gait)
% file names in dataset requires:
%   end with -personId.txt
% dataset_path: relative path of current working path
% fs: sampling rate of data
% gait: string of name of current gait
%
% eg: dataPreprocess('../../DATA/HMP_Dataset/Walk')
% 
% Pattern Recognition Project
% Author: Chen Liang
% Time: Nov-18-2015

if nargin < 5,
    gait = 'walking';
end

if nargin < 4,
    dataset_name = 'HMP';
end

% sampling rate conversion
default_fs = 32;
if nargin < 3,
    fs = default_fs;
end
[p, q] = rat(fs/default_fs);

% filter flag
if nargin < 2,
    filter_flag = 0;
end

files = dir([dataset_path '/*.txt']);
num_files = length(files);

field1 = 'personId';
field2 = 'data';
field3 = 'gait';
value1 = cell(0);
value2 = cell(0);
value3 = cell(0);
data_struct = struct(field1, value1, field2, value2, field3, value3);
for i = 1:num_files,
    disp(files(i).name);
    
    % get personId by text parsing
    personId = strsplit(files(i).name, '-');
    personId = personId{end};
    personId = strsplit(personId, '.');
    personId = personId{1};
    
    % get content in current file
    fileID = fopen([dataset_path '/' files(i).name], 'r');
    current_data = fscanf(fileID, '%f');
    fclose(fileID);
    
    % process data
    current_data = buffer(current_data, 3, 0,'nodelay');
    current_data = (-1.5 + (current_data/63) * 3) * 1000;
    current_data = resample(current_data', p, q)';
    
    % extra direction correction for different dataset
%     if dataset_name == 'HMP',
%         % do nothing
%     end

    % add noise filter --> Median filter
    if filter_flag,
        n = 3; % order
        current_data = medfilt1(current_data, n, [], 2);
    end

    try,
        index = strfind(data_struct.personId, personId);
        index = find(not(cellfun('isempty', index)));
    catch,
        % catch the first file in an empty struct
        index = -1;
    end

    % add to struct
    if index == -1,
        % first entry in the dataset
        data_struct(1).personId{1} = personId;
        data_struct(1).data{1} = cell(1);
        data_struct(1).data{1}{1} = current_data;
        data_struct(1).gait{1} = gait;
    elseif isempty(index),
        % first entry of a specific person
        data_struct.personId{end+1} = personId;
        data_struct.gait{end+1} = gait;
        data_struct.data{end+1} = cell(1);
        data_struct.data{end}{1} = current_data;
    else,
        % entries for an existed person
        data_struct.data{index}{end+1} = current_data;
    end
end