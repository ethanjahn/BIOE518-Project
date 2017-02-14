function table = numericOnly(table,type)
% Function takes a table as an input, only returns the numeric variables of
% the table

headers = table.Properties.VariableNames;
fprintf('====================================\n')
fprintf('Removed From Table of Type: %s\n',type)
for i = 1:width(table)
    if ~isnumeric(table.(headers{i}))
        table.(headers{i}) = [];
        fprintf('Removed Variable: %s\n',headers{i})
    end
end
fprintf('------------------------------------\n')
end