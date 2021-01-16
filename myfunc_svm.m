function label = myfunc_svm(X_all,Y_all,folds)
c = cvpartition(size(X_all,1),'KFold',folds);%random partition for K-fold cross-validation
set = [];
for i = 1:folds
    set(:,i) = training(c,i);
end
% hold off
% figure();%To visualize training and testing sets
% h = heatmap(set,'ColorbarVisible','off');
% % sorty(h,{'1','2','3','4','5','6','7','8','9','10'},'ascend')
% xlabel('Repetition')
% ylabel('Observation')
% title('Training Set Observations')

label = [];
for ii = 1:folds
    X = X_all(find(set(:,ii)==1),:);
    Y = Y_all(find(set(:,ii)==1),:);
    SVMModel = fitcsvm(X,Y,'KernelFunction','linear',...
    'Standardize',true,'ClassNames',[0,1]); %Linear kernel
    newX = X_all(find(set(:,ii)==0),:);
    [labels,score] = predict(SVMModel,newX);
    label(find(set(:,ii)==0),1) = labels;
end