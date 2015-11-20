data_struct = dataPreprocess('../../DATA/HMP_Dataset/Walk');
data_struct = projectData(data_struct);

% test on the first person in dataset: f1
eigens_f1 = data_struct.eigVec{1};
eigens_f1 = cell2mat(eigens_f1);
% get mean eigenvector on different trials
eigen_f1 = sum(eigens_f1, 2);
trials = data_struct.data{1};
projected_trials = [];
num_trials = length(trials);
margin = 3 * 32; % margin - samples in 3 seconds
min_length = 24 * 32; % a trial must at least has 24 seconds

% lengths = [];
% for i = 1:num_trials,
%     lengths = [lengths size(trials{i}, 2)];
% end
% min_length = min(lengths);

for i = 1:num_trials,
    trial = trials{i};
    if size(trial, 2) < min_length,
        continue
    end
    trial = trial(:, 1+margin:min_length-margin);
    projected_trials = [projected_trials; eigen_f1' * trial];
end
projected_trials = projected_trials';
trainingset = projected_trials(:, 2:end);

% compute mace filter on trianing data of one person
[h_mace, H_mace] = mace(trainingset);

% test
N = min_length - 2 * margin;

% data in training set
test = trainingset(:, 1);
correlation = real(ifft(fft(test) .* conj(H_mace))) * N;

% data of same person
f1_test = projected_trials(:, 1);
f1_correlation = real(ifft(fft(f1_test) .* conj(H_mace))) * N;

% data of different person
m1_test = eigen_f1' * data_struct.data{2}{1}(:, 1+margin:min_length-margin);
m1_test = m1_test';
m1_correlation = real(ifft(fft(m1_test) .* conj(H_mace))) * N;


x = linspace(1, N, N);
figure
    plot(x, correlation, '-.b', x, f1_correlation, '-', x, m1_correlation, '--');
    legend('trainind data', 'same person', 'different person');
    title('Correlation output of mace filter');