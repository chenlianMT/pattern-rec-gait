function [ good_stepsx,good_stepsy,good_stepsz ] = extract_steps_2(time_series, thresh, step_len )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
last_val = 0;
is_step = false;
stepsx_1 = [];
stepsy_1 = [];
stepsz_1 = [];
test_data = time_series(1,:);
%figure;
%hold on
num_steps = 0;
while num_steps < 5
    num_steps = 0;
    is_step = false;
    stepsx_1 = [];
    stepsz_1 = [];
    stepsy_1 = [];
    last_val = 0;
    for i = 1:length(test_data)
        cur_val = test_data(i);
        if (cur_val > thresh && last_val < thresh)
            if(i)
                is_step = true;
                num_steps = num_steps + 1;
            end
        end
        if(cur_val < last_val && is_step)
            if((i+step_len-2)>length(test_data))
                break;
            end
            %figure
            %plot(time_series(i-1:i+step_len-2));
            stepx = test_data(i-1:i+step_len-2);
            stepx = stepx ./ sqrt(sum(stepx.^2));
            stepy = time_series(2,i-1:i+step_len-2);
            stepy = stepy ./ sqrt(sum(stepy.^2));
            stepz = time_series(3,i-1:i+step_len-2);
            stepz = stepz ./ sqrt(sum(stepz.^2));
            stepsx_1 = [stepsx_1,stepx'];
            stepsy_1 = [stepsy_1,stepy'];
            stepsz_1 = [stepsz_1,stepz'];
            is_step = false;
        end
        last_val = cur_val;
    end
    thresh = thresh - .05;
end
[~, ~, steps_1_proj, ~] = PCA(stepsx_1, false);

label = multi_kmeans(steps_1_proj(1:5,:),3,100);

my_label = mode(label);
%figure
%hold on
good_stepsx = stepsx_1(:,label == my_label);
good_stepsy = stepsy_1(:,label == my_label);
good_stepsz = stepsz_1(:,label == my_label);
end

