data = dataPreprocess('../../DATA/HMP_Dataset/Walk');

data_filt = highPass_all(data,32,2);
data_raw = projectData(data_filt);
data_norm = projectData_norm(data);

person = 4;
trial = 3;


length_trial = length(data_raw.dataProj{person}{trial});
figure
plot(1:length_trial, data_raw.dataProj{person}{trial}, 'b');
title('After PCA on raw');
figure
plot(1:length_trial, -data_norm.dataProj{person}{trial}, 'r');
title('After PCA on norm');

%data_raw_filt = highPass(data_raw, 32, 5);

data_raw = extract_all_periods(data_raw,.5,32,50,10);
data_norm = extract_all_periods(data_norm,.5,32,50,10);

person1 = 9;
person2 = 1;
num_trials_1 = length(data_raw.steps{person1});
num_trials_2 = length(data_raw.steps{person2});
needs_first = 1;
for i = 1:num_trials_1
    if(needs_first)
        if(~isempty(data_raw.steps{person1}{i}))
            data1 = data_raw.steps{person1}{i};
            needs_first = 0;
        end
    else
        if(~isempty(data_raw.steps{person1}{i}))
            
            data1 = [data1,data_raw.steps{person1}{i}];
        end
    end
end
needs_first = 1;
for i = 1:num_trials_2
    if(needs_first)
        if(~isempty(data_raw.steps{person2}{i}))
            data2 = data_raw.steps{person2}{i};
            needs_first = 0;
        end
    else
        if(~isempty(data_raw.steps{person2}{i}))
            data2 = [data2,data_raw.steps{person2}{i}];
        end
    end
end

data_comb = [data1,data2];
labels = [ones(1,size(data1,2)),2*ones(1,size(data2,2))];
[vecs, lambdas] = LDA(data_comb,2,labels);
[~,ranks] = sort(lambdas, 'descend');
my_vecs = [vecs(:,ranks(1)),vecs(:,ranks(2))];
data1_2D = my_vecs'*data1;
data2_2D = my_vecs'*data2;
figure
plot(data1_2D(1,:),data1_2D(2,:), '*r');
hold on;
plot(data2_2D(1,:),data2_2D(2,:), '*b');
