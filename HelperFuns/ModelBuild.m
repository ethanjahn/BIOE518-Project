function [prediction,backLabel,importance,foldLoss] = ModelBuild(trainTable,responseVar,NLearn,LearnRate,KFold,testTable)

% Convert table to matrix
trainingMat = table2array(trainTable);
testMat = table2array(testTable);

% Parameters to optimize (MaxCat, NLearn, LearnRate)
t = templateTree('Surrogate','on','Prune','off');

RFmodel = fitensemble(trainingMat,responseVar,'AdaBoostM1',NLearn,t,'LearnRate',LearnRate,'KFold',KFold);
% Week 4: NLearn = 130, LearnRate = 0.4, 
% Week 5: NLearn = 300, LearnRate = 0.7, kfoldLoss = 0.351
% Week 6: NLearn = 300, LearnRate = 0.6, kfoldLoss = ???


for i = 1:size(RFmodel.Trained,1)
    prediction(:,i) = predict(RFmodel.Trained{i},testMat);
    backLabel(:,i) = predict(RFmodel.Trained{i},trainingMat);
    importance (:,i) = predictorImportance(RFmodel.Trained{i});
end

% Back label
backLabel(backLabel == -1) = 0;
backLabel = mean(backLabel,2);

% Convert all -1 to 0
prediction(prediction == -1) = 0;

% Find the mean of the predictions of the trained models
prediction = mean(prediction,2);

% Display kfold loss
foldLoss = kfoldLoss(RFmodel);
end