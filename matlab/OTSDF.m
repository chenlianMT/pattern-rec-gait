function [h, H] = OTSDF(x, alpha, u)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% H = OTSDF(x, u)
%   This script implements the Optimal Tradeoff Synthetic Discriminant
%   Function(OTSDF) filter.
%
%   x: a matrix with each column is a training instance.
%   u: is the expected correlation result of training instances and impulse
%   filter response, which is usually set as an all 1 vector
%   alpha: the weight for MVSDF and MACE filter. If alpha = 0, it's a MACE.
%   
%   h: OTSDF filter impulse response
%   H: OTSDF filter frequency response
%
%   Author: Chen Liang
%   Date: Dec 06, 2015
%   For 18-794 Pattern Recognition Project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[K, N] = size(x);
if nargin < 2,
    u = ones(N, 1);
end

% FFT of training data
X = fft(x);

% diaonal matrix of average power spectrum of the training images
D = diag(mean(X .* conj(X), 2));

% compute zero mean noise power density matrix
rng default
noise = randn(K * 2 + 2); % normally distributed noise
psd_noise = (1/length(noise)^2) * abs(fft(noise)).^2;
C = diag(psd_noise(1:K));

% compute compond filter matrix P
beta = sqrt(1 - alpha^2);
P = alpha * C + beta * D;

% compute OTSDF filter frequency response
H = (P\X) * ((ctranspose(X) * (P \ X))\u);
h = ifft(H);