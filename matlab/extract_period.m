function [t, steps] = extract_period( X, thres, Fs, step_size, nms_size, plotflag )
%EXTRACT_PERIOD 
% Given the accelerometer data and the sampling rate, determine the period
% of the person's action in second
% X        - data vector in either a row or a column
% thres    - correlation cutoff threshold between 0 and 1
% Fs       - sampling rate
% step_size- desired time-warpping step size
% nms_size - nms supression window size. If 0 then no nms.
% plotflag - 1 to plot the correlation, 0 otherwise
% t        = estimated period; if below threshold, return Inf
if numel(X) ~= length(X),
    error('Input must be a vector!');
end
r = xcorr(X,X,'unbiased');
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
    for i = 1:length(I)-1,
        step = X(I(i):I(i+1));
        steps(i,:) = resample(step,step_size,length(step));
    end
else
    t = Inf; % unable to determine the period
    steps = [];
end
if plotflag, figure(3); plot(repmat((0:step_size-1)',1,length(I)-1),...
        steps'); end
end

