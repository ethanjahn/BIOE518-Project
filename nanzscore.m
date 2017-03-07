function outmat = nanzscore(inmat)
% Calculates zscore for a matrix with NaN values while leaving NaN values
% untouched

% Array which repeats columns of the nanmean
meanArray = repmat(nanmean(inmat),size(inmat,1),1);
stdArray = repmat(nanstd(inmat),size(inmat,1),1);

outmat = (inmat - meanArray)./stdArray;
end