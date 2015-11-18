function data_struct = dataPreprocess(dataset_path, fs)
% dataset format requires:
% end with -personId.txt

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
    personId = strsplit(files(i).name, '-');
    personId = personId{end};
    personId = strsplit(personId, '.');
    personId = personId{1};
    
    % get content in current file
    fileID = fopen([dataset_path '/' files(i).name], 'r');
    current_data = fscanf(fileID, '%f');
    current_data = buffer(current_data, 3, 0,'nodelay');
    current_data = (-1.5 + (current_data/63) * 3) * 1000;
    fclose(fileID);
    
    try,
        index = strfind(data_struct.personId, personId);
        index = find(not(cellfun('isempty', index)));
    catch,
        % the 1st file added
        index = -1;
    end

    if index == -1,
        data_struct(1).personId{1} = personId;
        data_struct(1).data{1} = cell(1);
        data_struct(1).data{1}{1} = current_data;
    elseif isempty(index),
        data_struct.personId{end+1} = personId;
        data_struct.data{end+1} = cell(1);
        data_struct.data{end+1}{1} = current_data;
    else,
        data_struct.data{index}{end+1} = current_data;
    end
end