function table = ReadExcel(fileName)
% Outputs a table structure containing the contents of the input excel file

% Read excel file as a cell array to keep all data types
[~,~,raw] = xlsread(fileName);

% Separate data and headers
Data = raw(2:end,:);
Headers = raw(1,:);

% Remove CytoCat
Data(:,strcmp(Headers,'cyto.cat')) = [];
Headers(strcmp(Headers,'cyto.cat')) = [];

%Remove '#' and change '.' to '_' in Headers to make valid variables
Headers = regexprep(Headers,'#','');
Headers = regexprep(Headers,'\.','_');

% Replace NA with ND in 
relapseColumn = Data(:,strcmp(Headers,'Relapse'));
relapseColumn(strcmp(relapseColumn,'NA')) = {'ND'};
Data(:,strcmp(Headers,'Relapse')) = relapseColumn;

% Replace all 'NA' with NaN in floating point columns
Data(strcmp(Data,'NA')) = {NaN};

% Create table data structure and assign Headers
table = cell2table(Data);
table.Properties.VariableNames = Headers;


% Chemo simplest
% Std
% Anthra
% Flu
% HDAC
table.ChemoAraC = double(strcmp(table.Chemo_Simplest,'StdAraC-Plus'));
table.ChemoAnthra = double(strcmp(table.Chemo_Simplest,'Anthra-HDAC'));
table.ChemoFlu = double(strcmp(table.Chemo_Simplest,'Flu-HDAC'));
table.ChemoHDACPlus = double(strcmp(table.Chemo_Simplest,'HDAC-Plus non Anthra'));

disp(class(table.ChemoAraC))

end