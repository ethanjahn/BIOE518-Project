function [prediction,backLabelRF,importance] = ModelBuild(trainingMat,responseVar,NLearn,LearnRate,KFold,testMat)
% train RF model
%ExampleOptimize(trainingMat1,responseVar1)

% Parameters to optimize (MaxCat, NLearn, LearnRate)
t = templateTree('Surrogate','on','Prune','off');

RFmodel = fitensemble(trainingMat,responseVar,'AdaBoostM1',NLearn,t,'LearnRate',LearnRate,'KFold',KFold);
% Week 4: NLearn = 130, LearnRate = 0.4, 
% Week 5: NLearn = 300, LearnRate = 0.7, kfoldLoss = 0.351


for i = 1:size(RFmodel.Trained,1)
    prediction(:,i) = predict(RFmodel.Trained{i},testMat);
    backLabelRF(:,i) = predict(RFmodel.Trained{i},trainingMat);
    importance (:,i) = predictorImportance(RFmodel.Trained{i});
end

% Back label
backLabelRF(backLabelRF == -1) = 0;
backLabelRF = mean(backLabelRF,2);

% Convert all -1 to 0
prediction(prediction == -1) = 0;

% Find the mean of the predictions of the trained models
prediction = mean(prediction,2);

% Convert -1 to 0 in the response var for scoring
respVarScore = responseVar;
respVarScore(respVarScore == -1) = 0;

% Display kfold loss
RFkfold = kfoldLoss(RFmodel);

% BAC and AUROC
[RFbac,RFauroc] = score(backLabelRF,respVarScore);

end