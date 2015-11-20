function [data_struct] = highPass_all(data_struct, Fs, cutoff)
%data_struct: struct with the data to be filtered
%Fs: sample frequency of data
%cutoff: cutoff frequency in Hz

num_ppl = length(data_struct.personId);
for i = 1:num_ppl
    
    num_trials = length(data_struct.data{i});
    data_struct.period{i} = cell(1,num_trials);
    data_struct.steps{i} = cell(1,num_trials);
    for j = 1:num_trials
        data = data_struct.data{i}{j};
        dims = size(data,1);
        for k = 1:dims
            data(k,:) = highPass(data(k,:),Fs,cutoff);
        end
        data_struct.data{i}{j} = data;
    end
end


end

