function [ good_steps ] = extract_steps(time_series, thresh, step_len )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
last_val = 0;
is_step = false;
steps_1 = [];

%figure;
%hold on
num_steps = 0;
while num_steps < 7
    num_steps = 0;
    is_step = false;
    steps_1 = [];
    last_val = 0;
    for i = 1:length(time_series)
        cur_val = time_series(i);
        if (cur_val > thresh && last_val < thresh)
            if(i)
                is_step = true;
                num_steps = num_steps + 1;
            end
        end
        if(cur_val < last_val && is_step)
            if((i+step_len-2)>length(time_series))
                break;
            end
            %figure
            %plot(time_series(i-1:i+step_len-2));
            step = time_series(i-1:i+step_len-2);
            step = step ./ sqrt(sum(step.^2));
            steps_1 = [steps_1,step'];
            is_step = false;
        end
        last_val = cur_val;
    end
    thresh = thresh - .05;
end
[~, ~, steps_1_proj, ~] = PCA(steps_1, false);

label = multi_kmeans(steps_1_proj(1:5,:),3,100);

my_label = mode(label);
%figure
%hold on
good_steps = steps_1(:,label == my_label);

end

