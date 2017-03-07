function [BAC, AUROC] = score(prediction,actual) %TODO : Add in AUROC
% Scores based on challenge 1, compares the prediction rate for PR (primary
% resistant) and CR (complete remission)

predBAC = prediction;
predBAC(predBAC < 0.5) = 0;
predBAC(predBAC >= 0.5) = 1;

% Create a vector, where 0 represents an incorrect match, 1 represents a
% correct match
correctArray = zeros(1,length(actual));
correctArray(actual == predBAC) = 1;

% Using notation found on qutublab.org presentation on challenge
% Assuming CR prediction = 1
TP = sum(correctArray(actual == 1));
P = numel(actual(actual == 1));

% Assuming PR prediction = 0
TN = sum(correctArray(actual == 0));
N = numel(actual(actual == 0));

if (N+P) ~= numel(actual)
    disp('Error: Actual vector contains invalid elements (Elements other than 1 or 0)')
end
    
BAC = 1/2*(TP/P + TN/N);


%%%%%% AUROC
[~,~,~,AUROC] = perfcurve(actual,prediction,1);


end