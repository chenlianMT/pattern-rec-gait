function [x_lp] = highPass(x, Fs, cutoff)
%highPass
%data: 1D vector of data
%Fs: sample rate
%cuttoff: cuttoff frequency Hz

num_pts = length(x);
if(numel(x) ~= num_pts)
    disp('Error: data must be a vector');
    return
end

X = fft(x);
num_low = floor((cutoff/(2*Fs))*num_pts);
X(1:num_low) = 0;
X(end-num_low:end) = 0;
x_lp = real(ifft(X));

end

