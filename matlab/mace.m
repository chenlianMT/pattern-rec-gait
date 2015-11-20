function [h, H] = mace(x, u)
% x: M X N matrix of 1d time domain projected data of one person with N 
% trials and data length is M
% u: a N X 1 column vector 

[rows, cols] = size(x);
if nargin < 2,
    u = ones(cols, 1);
end

X = fft(x);
D = diag(mean(abs(X).^2, 2));

% inv(A) * B = A \ B
XDX = ctranspose(X) * (D \ X);
H = (D \ X) * (XDX \ u);
h = ifft(H);