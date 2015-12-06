
TRAIN = ;
TEST = ;
train_label = ;
test_label = ;
[vecs, lambdas, TRAINnew, meanX] = PCA(TRAIN);
[~,idx] = sort(lambdas,'descend');
dim = 30;
TRAINnew = TRAINnew(idx(1:dim),:);
vecs = vecs(:,idx(1:dim));
TESTnew = vecs' * (TEST-repmat(meanX,1,size(TEST,2)));

svm_model = svmtrain(train_label, TRAINnew, '-c 1 -g 0.07');
[predict_label, accuracy, ~] = svmpredict(test_label, TESTnew, svm_model);