function outTable = makeProteinTable(inTable)
% Creates a table of only protein data

% Extract headers from table
Headers = inTable.Properties.VariableNames;

firstProtein = 'ACTB';
lastProtein = 'ZNF346';

firstProteinIndex = find(strcmp(Headers,firstProtein));
lastProteinIndex = find(strcmp(Headers,lastProtein));

% Create the output table
outTable = inTable(:,firstProteinIndex:lastProteinIndex);
end