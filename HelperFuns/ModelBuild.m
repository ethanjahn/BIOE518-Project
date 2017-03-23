function [prediction,backLabel,importance,foldLoss] = ModelBuild(trainTable,responseVar,NLearn,LearnRate,KFold,testTable,NUM_PR_USED)

% Convert table to matrix
trainingMat = table2array(trainTable);
testMat = table2array(testTable);

% Parameters to optimize (MaxCat, NLearn, LearnRate)
t = templateTree('Surrogate','on','Prune','off');

% Record all rows to ensure that every row is used
unusedRows = 1:size(trainTable,1);

% Counters
% Count the iterations in the while loop
counterWhile = 0;
% Count the number of total models built (should be counterWhile * kfold)
counterPred = 0;

while ~isempty(unusedRows);
    counterWhile = counterWhile + 1;
    tic
    
    % Randomize the indices of PR patients and keep the top NUM_PR_USED
    % patients
    randIndPR = find(responseVar == -1);
    randIndPR = randIndPR(randperm(size(randIndPR,1)));
    randIndPR = randIndPR(1:NUM_PR_USED);
    
    % Randomize the indices of CR patients and keep the top NUM_PR_USED
    % patients 
    randIndCR = find(responseVar == 1);
    randIndCR = randIndCR(randperm(size(randIndCR,1)));
    randIndCR = randIndCR(1:NUM_PR_USED);
    
    % Combine and sort indices and removed used indices from unusedRows
    combinedInd = sortrows([randIndPR ; randIndCR]);
    unusedRows = setdiff(unusedRows,combinedInd);
    
    % Generate training mat and responseVar with the new indices
    balancedTrainer = trainingMat(combinedInd,:);
    balancedResponse = responseVar(combinedInd);
    
    
    RFmodel = fitensemble(balancedTrainer,balancedResponse,'AdaBoostM1',NLearn,t,'LearnRate',LearnRate,'KFold',KFold);
    % Week 4: NLearn = 130, LearnRate = 0.4,
    % Week 5: NLearn = 300, LearnRate = 0.7, kfoldLoss = 0.351
    % Week 6: NLearn = 300, LearnRate = 0.6, kfoldLoss = ???
    % Week 7:?
    % Week 8a: NLearn = 300, LearnRate = 0.6, kfoldLossCat = 0.45, Protein fold loss = 0.55
    
    
    for i = 1:size(RFmodel.Trained,1)
        counterPred = counterPred + 1;
        prediction(:,counterPred) = predict(RFmodel.Trained{i},testMat);
        backLabel(:,counterPred) = predict(RFmodel.Trained{i},trainingMat);
        importance (:,counterPred) = predictorImportance(RFmodel.Trained{i});
    end
    
    timeElapsed = toc;
    
    fprintf('Iteration: %i, Time: %.3f seconds\n',counterWhile,timeElapsed);
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