function [ data_struct ] = extract_all_periods(data_struct, thres, Fs, step_size, nms_size)
%Loops through the data in the data_struct and extracts all the periods
%into new fields in the struct
num_ppl = length(data_struct.personId);
data_struct = struct('personId', {data_struct.personId}, 'data', ...
    {data_struct.data}, 'gait', {data_struct.gait}, 'eigVec', ...
    {data_struct.eigVec}, 'dataProj', {data_struct.dataProj},...
    'period', {cell(1,num_ppl)}, 'steps', {cell(1,num_ppl)});
for i = 1:num_ppl
    
    num_trials = length(data_struct.data{i});
    data_struct.period{i} = cell(1,num_trials);
    data_struct.steps{i} = cell(1,num_trials);
    for j = 1:num_trials
        [period,steps] = extract_period(data_struct.dataProj{i}{j},...
            thres, Fs,step_size, nms_size, 0);
        data_struct.period{i}{j} = period;
        data_struct.steps{i}{j} = steps;
    end
end

end

