raw_data = dataPreprocess_HAR_raw();

%% plot raw_data body_x for subject 2 and subject 4
subject2 = raw_data.body_acc_x{1, 1};
subject4 = raw_data.body_acc_x{5, 1};
% plot(subject2);
% hold on;
% plot(subject4);

%% figure out the start and end for 15 periods of subject 2(do not use the start and end of an experiment)
first_2 = [82 137 192 250 310 369 425 481 537 601 662 719 775 830 890];
last_2 = [136 191 249 309 368 424 480 536 600 661 718 774 829 889 942];

%% figure out the start and end for 4 periods of subject 4
first_4 = [435 488 540 593];
last_4 = [487 539 592 644];

%% extract all of them, resample them into the same length, put into 3 groups
training = [];
std_pace_length = last_2(1) - first_2(1) + 1;
for i = 1:13, % 13 training data
    cur_pace = subject2(first_2(i):last_2(i))';
    cur_pace = resample(cur_pace, std_pace_length, length(cur_pace));
    training = [training cur_pace];
end

% 2 paces from the same person
pace_temp1 = subject2(first_2(end):last_2(end))';
pace_temp2 = subject2(first_2(end-1):last_2(end-1))';
testing_same = [resample(pace_temp1, std_pace_length, length(pace_temp1)) resample(pace_temp2, std_pace_length, length(pace_temp2))];

% 4 paces from different person(subject 4)
testing_diff = [];
for i = 1:length(first_4),
    cur_pace = subject4(first_4(i):last_4(i))';
    cur_pace = resample(cur_pace, std_pace_length, length(cur_pace));
    testing_diff = [testing_diff cur_pace];
end

%% normalize it or not (with a flag)
normalized = 1;
if (normalized),
    for i = 1:size(training, 2),
        training(:, i) = training(:, i)/norm(training(:, i));
    end
    for i = 1:size(testing_same, 2),
        testing_same(:, i) = testing_same(:, i)/norm(testing_same(:, i));
    end
    for i = 1:size(testing_diff, 2),
        testing_diff(:, i) = testing_diff(:, i)/norm(testing_diff(:, i));
    end
end

%% train otsdf filter based on first 13 periods of subject 1
alpha = 1;
[h_OTSDF, H_OTSDF] = OTSDF(training, alpha);

%% compute correlation
correlation_train = real(ifft(fft(training(:, 1)) .* conj(H_OTSDF))) * std_pace_length;
correlation_same = real(ifft(fft(testing_same(:, 1)) .* conj(H_OTSDF))) * std_pace_length;
correlation_diff = real(ifft(fft(testing_diff(:, 1)) .* conj(H_OTSDF))) * std_pace_length;

%% plot
x = linspace(1, std_pace_length, std_pace_length);
figure
    plot(x, correlation_train, '-.b', x, correlation_same, '-', x, correlation_diff, '--');
    legend('trainind data', 'same person', 'different person');
    title(sprintf('Correlation output of OTSDF filter alpha = %.2f', alpha));