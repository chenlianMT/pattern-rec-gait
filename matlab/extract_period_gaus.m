function [t, steps, step_orig_size] = extract_period_gaus( X, thres, Fs, std_dev, step_size, nms_size, plotflag )
%EXTRACT_PERIOD 
% Given the accelerometer data and the sampling rate, determine the period
% of the person's action in second
% X        - data vector in either a row or a column
% thres    - correlation cutoff threshold between 0 and 1
% Fs       - sampling rate
% std_dev  - Standard deviation of gaus filter in seconds
% step_size- desired time-warpping step size
% nms_size - nms supression window size. If 0 then no nms.
% plotflag - 1 to plot the correlation, 0 otherwise
% t        = estimated period; if below threshold, return Inf
if numel(X) ~= length(X),
    error('Input must be a vector!');
end
gaus = gausswin(length(X), Fs\3*length(X)/std_dev);
r = xcorr(X,gaus,'unbiased');
r = r(ceil(length(r)/2):end); % r is symmetrical
r = r / r(1); % normalize
if plotflag, figure(1); plot(0:(length(r)-1),r); end
if nms_size > 0, r = nms(r,nms_size); end;
if plotflag, figure(2); plot(0:(length(r)-1),r); end
[P,I] = findpeaks(r);
I = I(P>=thres);
%[Psort,Isort] = sort(P,'descend');
if length(I) > 1,
    t = mean(diff(I)) / Fs;
    steps = zeros(length(I)-1,step_size);
    step_orig_size = zeros(length(I),1);
    for i = 1:length(I)-1,
        step = X(I(i):I(i+1));
        step_orig_size(i) = length(step);
        step = resample(step,step_size,length(step));
        step = step - mean(step); % normalization
        step = step / norm(step);
        steps(i,:) = step;
    end
else
    t = Inf; % unable to determine the period
    steps = [];
    step_orig_size = 0;
end
if plotflag, figure(3); plot(repmat((0:step_size-1)',1,length(I)-1),...
        steps'); end
steps = steps';%added to make verticle data
end

