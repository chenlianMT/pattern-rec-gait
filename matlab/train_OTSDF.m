function [H_OTSDF, step_len] = train_OTSDF(raw_data, startInd, endInd, alpha, subject, num_experiments, xyz_flag)
% train_OTSDF is a function returns trained OTSDF on selected subject
%
% INPUT:
%       raw_data: raw data collected from HAR
%       startInd: index of starting points for each step, manual labels
%                 needed
%       endInd:   index of ending points for each step, manual labels
%                 needed
%       alpha:    alpha for OTSDF (default 0.01)
%       subject:  index of one subject to be trained (default 2)
%       num_experiments: the number of experiments to be trained (default 1)
%       xyz_flag: whether only x to be trained, or xyz axis to be trained (defalut 'xyz')
%
% OUTPUT:
%       H_OTSDF:  OTSDF filter for verification
%       step_len: standard step length

if (nargin < 7)
    xyz_flag = 'xyz';
    if (nargin < 6)
        num_experiments = 1;
        if (nargin < 5)
            subject = 2;
            if (nargin < 4)
                alpha = 0.01;
                if (nargin < 3)
                    if (nargin < 1)
                        error('HAR raw data is not passed');
                    end
                    error('manually labeled index for periods needed');
                end
            end
        end
    end             
end

% need to add 'num_experiments'
entries = find(raw_data.label_subject_raw == subject);
entry = entries(1);

dataVec = raw_data.body_acc_x{entry};
if strcmp(xyz_flag, 'xyz')
    dataVec = [dataVec; raw_data.body_acc_y{entry}];
    dataVec = [dataVec; raw_data.body_acc_z{entry}];
end

% extract steps, and contacnate xyz of the same step in a row
% one column in trainVec is one step, x - y - z
trainVec = [];
step_len = endInd(1) - startInd(1) + 1;
for i = 1:length(endInd)
    cur_trainVec = [];
    for row = 1:size(dataVec, 1)
        cur_step = dataVec(row, startInd(i):endInd(i));
        cur_step = resample(cur_step, step_len, length(cur_step));
        cur_trainVec = [cur_trainVec, cur_step];
    end
    trainVec = [trainVec; cur_trainVec];
end
trainVec = trainVec';

% normalize
for i = 1:size(trainVec, 2)
    trainVec(:, i) = trainVec(:, i)/norm(trainVec(:, i));
end

% train otsdf filte
[~, H_OTSDF] = OTSDF(trainVec, alpha);