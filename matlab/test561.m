clear;

% Control Parameters
DOPCA = 0;
DOLDA = 0;
DOIPCA = 1;
CV = 1;

DONOTHING = ~(DOPCA || DOLDA || DOIPCA);

[TRAIN, TEST] = dataPreprocess_HAR(0,1);
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


if CV,
    true_pos = 0;
    true_neg = 0;
    false_pos = 0;
    false_neg = 0;
    features = TRAIN.features_561;
    features = features';
    [vecs,lambda,new_features,~] = PCA(features,false);
    good_idx = lambda > 1;
    features = new_features(good_idx,:);
    labels = TRAIN.label_subject;
    num_subjects = max(labels);
    num_cross_val = 4;
    for i = 1:num_subjects
        pos_idx = find(labels == i);
        neg_idx = find(labels ~= i);
        num_test_pos = floor(length(pos_idx)/num_cross_val);
        num_test_neg = floor(length(neg_idx)/num_cross_val);
        for j = 1:num_cross_val
            start_test_pos = (j-1)*num_test_pos+1;
            end_test_pos = j*num_test_pos;
            test_idx_pos = pos_idx(start_test_pos:end_test_pos);
            train_idx_pos = [pos_idx(1:start_test_pos-1);pos_idx(end_test_pos+1:end)];
            test_features_pos = features(:,test_idx_pos);
            train_features_pos = features(:,train_idx_pos);
            
            start_test_neg = (j-1)*num_test_neg+1;
            end_test_neg = j*num_test_neg;
            test_idx_neg = neg_idx(start_test_neg:end_test_neg);
            train_idx_neg = [neg_idx(1:start_test_neg-1);neg_idx(end_test_neg+1:end)];
            test_features_neg = features(:,test_idx_neg);
            train_features_neg = features(:,train_idx_neg);
            
            test_features = [test_features_pos, test_features_neg];
            train_features = [train_features_pos, train_features_neg];
            test_labels = [ones(size(test_features_pos,2),1);...
                zeros(size(test_features_neg,2),1)];
            train_labels = [ones(size(train_features_pos,2),1);...
                zeros(size(train_features_neg,2),1)];
            test_features = test_features';
            train_features = train_features';
            svm_model = svmtrain(train_labels, train_features, '-t 0');
            [predict_label, accuracy, ~] = svmpredict(test_labels, test_features, svm_model);
            
            true_pos = true_pos + sum(predict_label & test_labels);
            true_neg = true_neg + sum(~predict_label & ~test_labels);
            false_neg = false_neg + sum(~predict_label & test_labels);
            false_pos = false_pos + sum(predict_label & ~test_labels);
        end
    end
end
true_pos_perc = true_pos/(true_pos + false_neg);
false_pos_perc = false_pos/(false_pos + true_neg);
%{
svm_model = svmtrain(train_label, train_new, '-t 0');
[predict_label, accuracy, ~] = svmpredict(test_label, test_new, svm_model);
%}