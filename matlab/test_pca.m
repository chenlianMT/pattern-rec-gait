if ~exist('data_raw','var'), % load data just once
    data_raw = dataPreprocess_HAR_raw();
end
%{
P1idx = data_raw.label_subject_raw == 1;
P2idx = data_raw.label_subject_raw == 2;
P1 = [cell2mat(data_raw.body_acc_x(P1idx)');...
      cell2mat(data_raw.body_acc_y(P1idx)');...
      cell2mat(data_raw.body_acc_z(P1idx)')];
P2 = [cell2mat(data_raw.body_acc_x(P2idx)');...
      cell2mat(data_raw.body_acc_y(P2idx)');...
      cell2mat(data_raw.body_acc_z(P2idx)')];
  
[P11vecs, P11lambdas, P11Xnew, P11meanX] = PCA(P1(:,1:1000));
[P12vecs, P12lambdas, P12Xnew, P12meanX] = PCA(P1(:,3001:4000));
[P21vecs, P22lambdas, P21Xnew, P21meanX] = PCA(P2(:,1:1000));
[P22vecs, P21lambdas, P22Xnew, P22meanX] = PCA(P2(:,1001:2000));
%}
stepsize = 500;
train_portion = 0.9; test_portion = 1 - train_portion;
TRAIN = [];
TEST = [];
for i = 1:30,
    disp(num2str(i));
    Piidx = data_raw.label_subject_raw == 1;
    Pi = [cell2mat(data_raw.body_acc_x(Piidx)');...
       cell2mat(data_raw.body_acc_y(Piidx)');...
       cell2mat(data_raw.body_acc_z(Piidx)')];
    Pi = Pi - repmat(min(Pi,[],2),1,size(Pi,2));
    Pi = Pi ./ repmat(max(Pi,[],2),1,size(Pi,2));
    [sx,sy,sz] = extract_steps_2(Pi,0.7, 55);
    [stepsize,numsamp] = size(sx);
    %Pi = Pi(:,1:(floor(size(Pi,2)/stepsize)*stepsize));
    numtrain = floor(numsamp * train_portion);
    numtest = numsamp - numtrain;
    for j = 1:numtrain,
        cur = [sx(:,j),sy(:,j),sz(:,j)]';
        [vecs,~,~,~] = PCA(cur);
        TRAIN = [TRAIN; reshape(vecs,1,9) i];
    end
    for j = 1:numtest,
        cur = [sx(:,j+numtrain),sy(:,j+numtrain),sz(:,j+numtrain)]';
        [vecs,~,~,~] = PCA(cur);
        TEST = [TEST; reshape(vecs,1,9) i];
    end
end

%% SVM
svm_model = svmtrain((TRAIN(:,end))+0, TRAIN(:,1:end-1), '-t 2');
[predict_label, accuracy, ~] = svmpredict((TEST(:,end))+0, TEST(:,1:end-1), svm_model);