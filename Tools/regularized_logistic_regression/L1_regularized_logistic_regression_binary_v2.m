function [accuracy, roc_x, roc_y, roc_t, auc, mcorr, selected_features,selected_weights, confusion_table] = L1_regularized_logistic_regression_binary_v2(X,Y,feature_names, isdisplay)

Y=Y(:)';
if size(X,2)==length(Y)
    X = X';
end

if ~exist('feature_names')
    feature_names = cell(1,size(X,2));
    for i=1:length(feature_names)
        feature_names{i} = ['x_',num2str(i)];
    end
end

if ~exist('isdisplay') || ~isequal(isdisplay,1)
    isdisplay=0;
end


cv_ind = crossvalind('Kfold', Y, 5);
preds2 = zeros(size(Y));
for i=1:5
    train_X = X(cv_ind~=i,:);
    train_Y = Y(cv_ind~=i);
    test_X = X(cv_ind==i,:);
    test_Y = Y(cv_ind==i);
    
    [B,FitInfo] = lassoglm(train_X,train_Y(:),'binomial','NumLambda',25,'CV',5,'Standardize',false);
    indx = FitInfo.Index1SE;
    if sum(B(:,indx)~=0)==0
        indx = FitInfo.IndexMinDeviance;
    end
    B0 = B(:,indx);
    selected_features = feature_names(B0~=0);
    selected_weights = B0(B0~=0);
    cnst = FitInfo.Intercept(indx);
    B1 = [cnst;B0];
    
    predictors = find(B0); % indices of nonzero predictors
    mdl = fitglm(train_X,train_Y,'linear','Distribution','binomial','PredictorVars',predictors);
    preds2(cv_ind==i) = predict(mdl, test_X);
end

%[~,~,~,auc1] = perfcurve(Y(:)',preds(:)',1);
[roc_x,roc_y,roc_t,auc2] = perfcurve(Y(:)',preds2(:)',1);
%accuracy1 = mean(preds>0.5 == Y(:));
accuracy2 = mean(preds2(:)>0.5 == Y(:));

if isdisplay==1
    plotroc(Y(:)',preds(:)','optimistic',Y(:)',preds2(:)','realistic')
    accuracy1
    accuracy2
    auc1
    auc2
end

accuracy = accuracy2;
auc = auc2;
confusion_table = confusionmat(double(preds2>0.5),double(Y));

TN = confusion_table(1,1);
TP = confusion_table(2,2);
FN = confusion_table(1,2);
FP = confusion_table(2,1);
mcorr = (TP*TN - FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
