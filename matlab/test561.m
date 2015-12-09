clear;

% Control Parameters
DOPCA = 0;
DOLDA = 0;
DOIPCA = 1;

DONOTHING = ~(DOPCA || DOLDA || DOIPCA);

[TRAIN, TEST] = dataPreprocess_HAR(30,1);
%train_idx = (train_activity == 1);
%test_idx = (test_activity == 1);
%TRAIN = TRAIN'; TRAIN = TRAIN(:,train_idx);
%TEST = TEST'; TEST = TEST(:,test_idx);
%train_label = train_label(train_idx);
%test_label = test_label(test_idx);
train_label = TRAIN.label_subject;
test_label = TEST.label_subject;
train = TRAIN.features_561;
test = TEST.features_561;
%%{
if DOPCA,
[vecs, lambdas, train_new, meanX] = PCA(train');
[~,idx] = sort(lambdas,'descend');
dim = sum(double(lambdas > 1));
train_new = train_new(idx(1:dim),:);
vecs = vecs(:,idx(1:dim));
train_new = train_new';
test_new = (vecs' * (test'-repmat(meanX,1,size(test,1))))';
end
%}
if DOLDA,
[ vecs, lambdas ] = LDA(train', 30, train_label);
[~,idx] = sort(lambdas,'descend');
dim = sum((lambdas > 1));
vecs = vecs(:,idx(1:dim));
train_new = (vecs' * train')';
test_new = (vecs' * test')';
end

if DOIPCA,
train_ipca = cell(30,2);
for c = 1:30,
    cur_train = train(TRAIN.label_subject==c,:);
    [vecs, lambdas, train_new, meanX] = PCA(cur_train');
    [~,idx] = sort(lambdas,'descend');
    dim = sum(double(lambdas > 1));
    train_ipca{c,1} = vecs(:,idx(1:dim));
    train_ipca{c,2} = meanX;
end

err = zeros(size(test,1),30);
for c = 1:30,
    test_m0 = (test'-repmat(train_ipca{c,2},1,size(test,1)))';
    test_proj = (test_m0 * train_ipca{c,1});
    test_recon = (test_proj * train_ipca{c,1}');
    err(:,c) = sum((test_recon - test).^2,2);
end
[~,ipca_label] = min(err,[],2);
accu = sum((ipca_label==test_label)+0)/length(test_label);
end

if DONOTHING,
    train_new = train;
    test_new = test;
end

svm_model = svmtrain(train_label, train_new, '-t 0');
[predict_label, accuracy, ~] = svmpredict(test_label, test_new, svm_model);