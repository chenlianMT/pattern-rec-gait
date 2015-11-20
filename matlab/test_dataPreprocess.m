data = dataPreprocess('../../DATA/HMP_Dataset/Walk', 1);
data_raw = projectData(data);
data_norm = projectData_norm(data);

person = 1;
trial = 3;

length_trial = length(data_raw.dataProj{person}{trial});
figure
plot(1:length_trial, data_raw.dataProj{person}{trial}, 'b');
title('After PCA on raw');
figure
plot(1:length_trial, -data_norm.dataProj{person}{trial}, 'r');
title('After PCA on norm');

data_raw = extract_all_periods(data_raw,.5,32,10);
data_norm = extract_all_periods(data_norm,.5,32,10);
