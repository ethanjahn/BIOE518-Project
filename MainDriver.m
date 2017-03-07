%%%%%%%%%%%% ADD APPROPRIATE PATHS %%%%%%%%%
addpath('HelperFuns')
addpath('Input')
addpath('Outputs')

%%%%%%%%%%%%% READING DATA %%%%%%%%%%%%%%%%%
% Read training data
if exist('trainingMat1','var') == 0
    trainingFile = '/Input/trainingData-release_cytocat.xlsx';
    tbl = ReadExcel(trainingFile);

    tbl = tableClean(tbl,'train');

    tblBackup = tbl;
end

% Read test data
if exist('testMat1','var') == 0
    testFile = '/Input/scoringData-release_cytocat.xlsx';
    testTable = ReadExcel(testFile);
    
    testTable = tableClean(testTable,'test');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% SC1 %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert to ML friendly matrix
%   Training
[trainingMat1,responseVar1,~,headers1] = tblSC(tbl,'train',1);

% Y scramble training
%responseVar1 = responseVar1(randperm(length(responseVar1)));

%   Testing
[testMat1,~,nanRows1] = tblSC(testTable,'test',1);

%{
%%%%%% SVM %%%%%%%
% train SVM model
SVMmodel = fitcsvm(trainingMat1,responseVar1);

% Use SVM model to back predict to get scores
backLabelSVM = predict(SVMmodel,trainingMat1);

% Predictions for test matrix
SVMout = predict(SVMmodel,testMat1);

% Cross-validation
SVMcross = crossval(SVMmodel);

% Display kfold loss
SVMkfold = kfoldLoss(SVMcross);

% BAC and AUROC
[SVMbac,SVMauroc] = score(backLabelSVM,responseVar1);

fprintf('=====================\n')
fprintf('For SVM:\n')
fprintf('BAC: %.3f\n',SVMbac)
fprintf('AUROC: %.3f\n',SVMauroc)
fprintf('kfold Loss: %.3f\n',SVMkfold)
fprintf('---------------------\n')
%%%%%%%%%%%%%%%%%%
%}

%%%%%% ADA %%%%%%%
% train RF model
%ExampleOptimize(trainingMat1,responseVar1)

% Parameters to optimize (MaxCat, NLearn, LearnRate)
t = templateTree('Surrogate','on','Prune','off');

RFmodel = fitensemble(trainingMat1,responseVar1,'AdaBoostM1',300,t,'LearnRate',0.6,'KFold',50);
% Week 4: NLearn = 130, LearnRate = 0.4, 
% Week 5: NLearn = 300, LearnRate = 0.7, kfoldLoss = 0.351


for i = 1:size(RFmodel.Trained,1)
    prediction(:,i) = predict(RFmodel.Trained{i},testMat1);
    backLabelRF(:,i) = predict(RFmodel.Trained{i},trainingMat1);
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
respVarScore = responseVar1;
respVarScore(respVarScore == -1) = 0;

% Display kfold loss
RFkfold = kfoldLoss(RFmodel);

% BAC and AUROC
[RFbac,RFauroc] = score(backLabelRF,respVarScore);


fprintf('=====================\n')
fprintf('For RF:\n')
fprintf('BAC: %.3f\n',RFbac)
fprintf('AUROC: %.3f\n',RFauroc)
fprintf('kfold Loss: %.3f\n',RFkfold)
fprintf('Num of PR Predictions: %.0f\n',sum(prediction < 0.5))
fprintf('---------------------\n')

% Mean predictor importances
meanImportance = mean(importance');
% Normalize to max importance
meanImportance = meanImportance./max(meanImportance);

fprintf('=====================\n')
fprintf('Predictor\t  Relative Importance\n')
for n = 1:numel(headers1)
    fprintf('%-15s:%15.3f\n',headers1{n},meanImportance(n));
end
fprintf('---------------------\n')
%writeToOutput('Outputs/HewesTanZhuJahn_Week4_SC1.txt',prediction,1)
%%%%%%%%%%%%%%%%%%

%{
%%%%%%% PRINT TO OUTPUT FILE %%%%%%%%%
writeToOutput('Outputs/HewesTanZhuJahn_Week2_SC1.txt',SVMout,nanRows1,0.5,1)

%%%%%%%%%%%%%%%%%%%%%%% Subchallenge 2 %%%%%%%%%%%%%%%%%
% Convert to ML friendly matrix
%   Training
[trainingMat2,responseVar2] = tblSC(tbl,'train',2);
%   Testing
[testMat2,~,nanRows2] = tblSC(testTable,'test',2);
%   Cox fit
[b2,logl2,H2,stats2] = coxphfit(trainingMat2,responseVar2);

meanRemission = mean(responseVar2);

% Remove zero values
for patient = 1:size(testMat2,1);
    estRemission(patient) = meanRemission*exp(sum(b2'.*testMat2(patient,:)));
end

writeToOutput('Outputs/HewesTanZhuJahn_Week2_SC2.txt',estRemission,nanRows2,meanRemission,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%% Subchallenge 3 %%%%%%%%%%%%%%%%%
% Convert to ML friendly matrix
%   Training
[trainingMat3,responseVar3] = tblSC(tbl,'train',3);
%   Testing
[testMat3,~,nanRows3] = tblSC(testTable,'test',3);
% Cox fit
[b3,logl3,H3,stats3] = coxphfit(trainingMat3,responseVar3);

meanSurvival = mean(responseVar3);

% Remove zero values
for patient = 1:size(testMat3,1);
    estSurvival(patient) = meanSurvival*exp(sum(b3'.*testMat3(patient,:)));
end

writeToOutput('Outputs/HewesTanZhuJahn_Week2_SC3.txt',estSurvival,nanRows3,meanSurvival,3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}