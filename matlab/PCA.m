function [vecs, lambdas, Xnew, meanX] = PCA(X, is_zero_mean)
%PCA: perform PCA on a dataset X to reduce the dimensions to the number in
%num_feat.  The vectors to represent the new space are returned in vecs
%with their eigenvalues in lambdas.  The projected X vectors are returned
%in Xnew

if(~exist('is_zero_mean', 'var'))
    is_zero_mean = false;
end

[dims, num_points] = size(X);

if(~is_zero_mean)
    meanX = mean(X, 2);
    meanX_mat = repmat(meanX,[1,num_points]);
    X = X - meanX_mat;
else
    meanX = zeros(dims,1);
end

if(dims > num_points)
    [vecs, lambdas] = gram_pca(X);
else
    [vecs, lambdas] = norm_pca(X);
end

Xnew = vecs'*X;


end

function [vecs, lambdas] = gram_pca(X)
gram_mat = X'*X;
[vecs, lambdas] = eig(gram_mat);
lambdas = diag(lambdas);
vecs = X*vecs;
end

function [vecs, lambdas] = norm_pca(X)
gram_mat = X*X';
[vecs, lambdas] = eig(gram_mat);
lambdas = diag(lambdas);
end