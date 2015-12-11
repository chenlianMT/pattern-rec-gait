function test_Vec = extract_OTSDF(dataVec, step, thresh)

plotflag = 0;
if (nargin < 3),
    thresh = .04;
end
t = linspace(0, length(dataVec), length(dataVec));

last_val = 0;
is_step = false;
step_start = [];

% normalize
dataVec_ = dataVec/norm(dataVec);

for i = 1:length(dataVec)
    cur_val = dataVec_(i);
    if (cur_val > thresh && last_val < thresh)
        is_step = true;
    end
    if(cur_val < last_val && is_step)
        step_start = [step_start, i];
        is_step = false;
    end
    last_val = cur_val;
end
step_start = step_start(1:end-1);

% length contraint
delta_t = 15;
step_start_ref = [-Inf step_start(1:end-1)];
step_start_diff = step_start - step_start_ref;

step_start = step_start(step_start_diff > delta_t);

if plotflag
    plot(t, dataVec);
    hold on
    plot(step_start, dataVec(step_start),'*');
end

% extract all and resample
test_Vec = [];
i = 1;
while (true)
    cur_step = dataVec(step_start(i):step_start(i + 2));
    cur_step = resample(cur_step, step, length(cur_step));
    test_Vec = [test_Vec; cur_step];
    i = i + 2;
    if i + 2 > length(step_start)
        break;
    end
    if step_start(i+2) > length(dataVec)
        break;
    end
end
test_Vec = test_Vec';

if plotflag
    figure
    for i = 1:size(test_Vec, 2)
        plot(test_Vec(:, i))
        hold on
    end
end
