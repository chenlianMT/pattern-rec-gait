function correlation_score = verify_OTSDF(raw_data, subject, step_length, H_OTSDF, experiment_index, xyz_flag)
% verify_OTSDF is a function returns correlation score of current subject
%
% INPUT:
%       raw_data: raw data collected from HAR
%       subject:  index of one subject to be trained
%       step_len: standard step length
%       H_OTSDF:  OTSDF filter for verification
%       experiment_index: the index of experiment to be trained (default 1)
%       xyz_flag: whether only x to be trained, or xyz axis to be trained (defalut 'xyz')
%
% OUTPUT:
%       correlation_score: average correlation score of all windows of this
%                          subject. (see TODO for improvement)
%       

% TODO: extract periods and resample to step_length. In the current
% version, a sliding window of step_length is used.

if (nargin < 6)
    xyz_flag = 'xyz';
    if (nargin < 5)
        experiment_index = 1;
    end
end

% divide the experiment into frames, with same length of perfect step
% length
entries = find(raw_data.label_subject_raw == subject);
entry = entries(experiment_index);
dataVec = raw_data.body_acc_x{entry};
testVec = buffer(dataVec(1, :), step_length, 0, 'nodelay');
if strcmp(xyz_flag, 'xyz')
    dataVec = [dataVec; raw_data.body_acc_y{entry}];
    testVec = [testVec; buffer(dataVec(2, :), step_length, 0, 'nodelay')];
    
    dataVec = [dataVec; raw_data.body_acc_z{entry}];
    testVec = [testVec; buffer(dataVec(3, :), step_length, 0, 'nodelay')];
end

% normalize
for i = 1:size(testVec, 2)
    testVec(:, i) = testVec(:, i)/norm(testVec(:, i));
end

% get the max of correlation of current frame
scores = [];
for col = 1:size(testVec, 2)
    correlation = real(ifft(fft(testVec(:, col)) .* conj(H_OTSDF))) * step_length;
    scores = [scores, max(correlation)];
end

% get the average of all windows
correlation_score = mean(scores);