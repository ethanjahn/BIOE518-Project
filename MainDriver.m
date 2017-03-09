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
[trainingMat1,responseVar1,~,headers1,proteinMat,proteinHeaders] = tblSC(tbl,'train',1);

% Y scramble training
%responseVar1 = responseVar1(randperm(length(responseVar1)));

%   Testing
[testMat1,~,nanRows1,~,proteinTest] = tblSC(testTable,'test',1);

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

% Hyperparams
NLearn = 300;
LearnRate = 0.6;
KFold = 50;

%%%%%% ADA %%%%%%%
% train RF model
[prediction,BackLabelRF,importance] = ModelBuild(trainingMat1,responseVar1,NLearn,LearnRate,KFold,testMat1);

%%%%%%% PROTEIN MODEL %%%%%%%%
[predictionProt,BackLabelRFProt,importanceProt] = ModelBuild(proteinMat,responseVar1,NLearn,LearnRate,KFold,proteinTest);

%%%%%% COMBINE MODELS %%%%%%%
proteinWeight = 0.2;
categoryWeight = 1 - proteinWeight;

predictionCombined = proteinWeight.*predictionProt + categoryWeight.*prediction;
backLabelCombined = BackLabelRFProt.*proteinWeight + categoryWeight.*BackLabelRF;

%{
fprintf('=====================\n')
fprintf('For RF:\n')
fprintf('BAC: %.3f\n',RFbac)
fprintf('AUROC: %.3f\n',RFauroc)
fprintf('kfold Loss: %.3f\n',RFkfold)
fprintf('Num of PR Predictions: %.0f\n',sum(prediction < 0.5))
fprintf('---------------------\n')
%}

importancePrint(importance,headers1)
importancePrint(importanceProt,proteinHeaders)


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