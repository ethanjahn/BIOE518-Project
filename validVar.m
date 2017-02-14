function OutStr = validVar(varname)
% Cleans up variable names that have invalid characters
varname = regexprep(varname,'-','');
varname = regexprep(varname,',','');
varname = regexprep(varname,'+','');
varname = regexprep(varname,';','');

if ~isvarname(varname)
    fprintf('Invalid variable named: %s\n',cellstr(varname))
else
    OutStr = varname;
end
end