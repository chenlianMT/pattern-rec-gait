clear;

% Control Parameters
DOPCA = 1;
DOLDA = 0;

[TRAIN, TEST] = dataPreprocess_HAR(50);
train_idx = (train_activity == 1);
test_idx = (test_activity == 1);
TRAIN = TRAIN'; TRAIN = TRAIN(:,train_idx);
TEST = TEST'; TEST = TEST(:,test_idx);
train_label = train_label(train_idx);
test_label = test_label(test_idx);
%%{
if DOPCA,
[vecs, lambdas, TRAINnew, meanX] = PCA(TRAIN);
[~,idx] = sort(lambdas,'descend');
dim = sum(double(lambdas > 1));
TRAINnew = TRAINnew(idx(1:dim),:);
vecs = vecs(:,idx(1:dim));
TESTnew = vecs' * (TEST-repmat(meanX,1,size(TEST,2)));
end
%}
if DOLDA,
[ vecs, lambdas ] = LDA(TRAIN, 30, train_label);
[~,idx] = sort(lambdas,'descend');
dim = sum((lambdas > 1));
TRAINnew = TRAINnew(idx(1:dim),:);
vecs = vecs(:,idx(1:dim));
TESTnew = vecs' * TEST;
end


svm_model = svmtrain(train_label, TRAIN', '-c 1 -g 0.03');
[predict_label, accuracy, ~] = svmpredict(test_label, TEST', svm_model);