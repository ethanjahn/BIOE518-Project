function importancePrint(importance,headers)

% Mean predictor importances
meanImportance = mean(importance');
% Normalize to max importance
meanImportance = meanImportance./max(meanImportance);

fprintf('=====================\n')
fprintf('Predictor\t  Relative Importance\n')
for n = 1:numel(headers)
    fprintf('%-15s:%15.3f\n',headers{n},meanImportance(n));
end
fprintf('---------------------\n')

end