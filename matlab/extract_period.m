function [ t ] = extract_period( X, thres, Fs, nms_size, plotflag )
%EXTRACT_PERIOD 
% Given the accelerometer data and the sampling rate, determine the period
% of the person's action in second
% X        - data vector in either a row or a column
% thres    - correlation cutoff threshold between 0 and 1
% Fs       - sampling rate
% nms_size - nms supression window size. If 0 then no nms.
% plotflag - 1 to plot the correlation, 0 otherwise
% t        = estimated period; if below threshold, return Inf
if numel(X) ~= length(X),
    error('Input must be a vector!');
end
r = xcorr(X,X,'biased');
r = r(ceil(length(r)/2):end); % r is symmetrical
r = r / r(1); % normalize
if plotflag, figure(1); plot(0:(length(r)-1),r); end
if nms_size > 0, r = nms(r,nms_size); end;
if plotflag, figure(2); plot(0:(length(r)-1),r); end
[P,I] = findpeaks(r);
[Psort,Isort] = sort(P,'descend');
if Psort(1) >= thres,
    t = (I(Isort(1))-1) / Fs;
else
    t = Inf; % unable to determine the period
end
end

