%%%%%%%%%%%% ADD APPROPRIATE PATHS %%%%%%%%%
addpath('HelperFuns')
addpath('Input')
addpath('Outputs')

%%%%%%%%%%%%% READING DATA %%%%%%%%%%%%%%%%%
% Read training data
trainingFile = '/Input/trainingData-release_cytocat.xlsx';
tbl = ReadExcel(trainingFile);

tbl = tableClean(tbl,'train');

% Read test data
testFile = '/Input/scoringData-release_cytocat.xlsx';
testTable = ReadExcel(testFile);

testTable = tableClean(testTable,'test');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% SC1 %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert to ML friendly matrix
%   Training
[trainingMat1,responseVar1] = tblSC(tbl,'train',1);
%   Testing
[testMat1,~,nanRows1] = tblSC(testTable,'test',1);

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

%%%%%% ADA %%%%%%%
% train RF model
RFmodel = fitensemble(trainingMat1,responseVar1,'AdaBoostM1',100,'Tree');

% Use RF model to back predict to get scores
backLabelRF = predict(RFmodel,trainingMat1);

% Predictions for test matrix
RFout = predict(RFmodel,testMat1);

% Cross validate
RFcross = crossval(RFmodel);

% Display kfold loss
RFkfold = kfoldLoss(RFcross);

% BAC and AUROC
[RFbac,RFauroc] = score(backLabelRF,responseVar1);

fprintf('=====================\n')
fprintf('For RF:\n')
fprintf('BAC: %.3f\n',RFbac)
fprintf('AUROC: %.3f\n',RFauroc)
fprintf('kfold Loss: %.3f\n',RFkfold)
fprintf('---------------------\n')
%%%%%%%%%%%%%%%%%%

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