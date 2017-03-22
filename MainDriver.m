%%%%%%%%%%% USER INPUTS %%%%%%%%%%%%
% Hyperparams
NLearn = 50;
LearnRate = 1;
KFold = 2;

% Weight for protein forest
proteinWeight = 0.4;

%%%% Feature Selection %%%
weightCell = {
    'cyto_cat_score',1;
    'PRIOR_MAL',1;
    'ITD',1;
    'D835',1;
    'Age_at_Dx',1;
    'WBC',1;
    'BM_MONOCYTES',1;
    'PB_BLAST',1;
    'PB_MONO',1;
    'BM_ABS_RATIO',1;
    'SEX',1;
    };

% Marginal patient tolerance
patientTol = 0.2;

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

%%%%%%%%%%%%%%%% SC1 %%%%%%%%%%%%%%%%%%%%%%
% Convert to ML friendly matrix
%   Training
[trainingTableAll,responseVar] = tblPrep(tbl,'train');
% Apply weights to table to create categorical data table
trainingTableCat = weightTable(trainingTableAll,weightCell);
% get protein training table
trainingTableProtein = makeProteinTable(trainingTableAll);

% Y scramble training
%responseVar1 = responseVar1(randperm(length(responseVar1)));

%   Testing
testTableAll = tblPrep(testTable,'test');
% Apply weights to table
testTableCat = weightTable(testTableAll,weightCell);
% Get protein test table
testTableProtein = makeProteinTable(testTableAll);

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
[prediction,BackLabel,importance,foldLossCat] = ModelBuild(trainingTableCat,responseVar,...
    NLearn,LearnRate,KFold,testTableCat);

%%%%%%% PROTEIN MODEL %%%%%%%%
[predictionProt,BackLabelProt,importanceProt,foldLossProt] = ModelBuild(trainingTableProtein,responseVar,...
    NLearn,LearnRate,KFold,testTableProtein);

%%%%%% COMBINE MODELS %%%%%%%
categoryWeight = 1 - proteinWeight;

% Combine predictions
predictionCombined = proteinWeight.*predictionProt + categoryWeight.*prediction;
% Combine backlabel for self-scoring
backLabelCombined = BackLabelProt.*proteinWeight + categoryWeight.*BackLabel;

% Convert -1 to 0 in the response var for scoring
respVarScore = responseVar;
respVarScore(respVarScore == -1) = 0;

% Score the back labelled
[BAC,AUROC] = score(backLabelCombined,respVarScore);

fprintf('=====================\n')
fprintf('BAC: %.3f\n',BAC)
fprintf('AUROC: %.3f\n',AUROC)
fprintf('Cat Fold Loss: %.3f\n',foldLossCat)
fprintf('Protein Fold Loss: %.3f\n',foldLossProt)
fprintf('Num of PR Predictions: %.0f\n',sum(prediction < 0.5))
fprintf('---------------------\n')

importance = mean(importance,2);
importance = importance./max(importance);

importanceProt = mean(importanceProt,2);
importanceProt = importanceProt./max(importanceProt);

importanceTableCat = table(testTableCat.Properties.VariableNames',importance);
importanceTableProt = table(testTableProtein.Properties.VariableNames',importanceProt);

disp(sortrows(importanceTableCat,2,{'descend'}))
disp(sortrows(importanceTableProt,2,{'descend'}))


%writeToOutput('Outputs/HewesTanZhuJahn_Week4_SC1.txt',prediction)
%%%%%%%%%%%%%%%%%%
