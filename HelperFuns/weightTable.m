function outTable = weightTable(inTable,weightCell)

Headers = inTable.Properties.VariableNames;

%%%%%%%%%%%%% WEIGHTING %%%%%%%%%%%%%%%%%%%
% Create a weighting struct
for i = 1:size(inTable,2)
    weight.(Headers{i}) = 0;
end

% Adjust the weightings to the new weightings
for i = 1:size(weightCell,1)
    weight.(weightCell{i,1}) = weightCell{i,2};
end

% Convert weight structure to matrix to preserve ordering in case the order
% eventually gets changed
weight = struct2cell(weight);
weight = cell2mat(weight);
weight = weight';

% Convert the input table to an array
tableArray = table2array(inTable);

% Multiply the training matrix by the weights
weight = repmat(weight,size(tableArray,1),1);
tableArray = tableArray.*weight;

% Remove zero columns
Headers(~any(tableArray)) = [];
tableArray(:,~any(tableArray)) = [];

% Convert back to table for export
outTable = array2table(tableArray);
outTable.Properties.VariableNames = Headers;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end