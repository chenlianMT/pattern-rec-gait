data = dataPreprocess('../../DATA/HMP_Dataset/Walk',.25);

data_filt = highPass_all(data,32,1);
data_filt = projectData(data_filt);
data_norm = projectData(data);

person = 7;
trial = 2;


length_trial = length(data_filt.dataProj{person}{trial});
figure
plot(1:length_trial, data_filt.dataProj{person}{trial}, 'r');
title('Filtered Data');
figure
plot(1:length_trial, -data_norm.dataProj{person}{trial}, 'b');
title('Unfiltered data');

figure
plot(data_filt.data{person}{trial}')
figure
plot(data_filt.dataProj{person}{trial},'r')
%data_raw_filt = highPass(data_raw, 32, 5);


%plot(xcorr(test_dat, gaus, 'unbiased'));

data_raw = extract_all_periods_gaus(data_raw,.5,32,.3,50,10);
data_norm = extract_all_periods_gaus(data_norm,.5,32,.3,50,10);

person1 = 9;
person2 = 8;
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
