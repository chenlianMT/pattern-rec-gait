function [ data_struct ] = extract_all_periods(data_struct, thres, Fs, nms_size)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
num_ppl = length(data_struct.personId);
data_struct = struct('personId', {data_struct.personId}, 'data', ...
    {data_struct.data}, 'gait', {data_struct.gait}, 'eigVec', ...
    {data_struct.eigVec}, 'dataProj', {data_struct.dataProj},...
    'period', {cell(1,num_ppl)});
for i = 1:num_ppl
    
    num_trials = length(data_struct.data{i});
    data_struct.period{i} = cell(1,num_trials);
    for j = 1:num_trials
        data_struct.period{i}{j}= extract_period(data_struct.dataProj{i}{j},...
            thres, Fs, nms_size, 0);
    end
end

end

