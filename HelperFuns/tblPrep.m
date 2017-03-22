function [outputTable,responseVar] = tblPrep(tbl,type)

% Add additional features as necessary
tbl.BM_ABS_RATIO = tbl.BM_BLAST ./ tbl.ABS_BLST;
tbl.BM_ABS_RATIO(tbl.BM_ABS_RATIO == Inf) = 0;
tbl.BM_ABS_RATIO(isnan(tbl.BM_ABS_RATIO)) = 0;

% Identify the response variable
responseCol = 'resp_simple';

% Remove columns that are irrelevant for SC1
if strcmp(type,'train')
    tbl.Overall_Survival = [];
    tbl.vital_status = [];
    tbl.Remission_Duration = [];
end

% Convert table to array and header vector
tblData = table2array(tbl);
Headers = tbl.Properties.VariableNames;

if strcmp(type,'train')
    % If training dataset, remove the response variable and export it
    responseVar = tblData(:,strcmp(Headers,responseCol));
    
    tblData(:,strcmp(Headers,responseCol)) = [];
    
    Headers(strcmp(Headers,responseCol)) = [];
    
elseif strcmp(type,'test')
    responseVar = [];
else
    disp('Error: Wrong type in tblSC')
end

%%%%%%%%%%%%% NORMALIZE %%%%%%%%%%%%%%%%%%%%
% Normalize the training matrix by the nanZscore (leaves NaN values)
normalMat = nanzscore(tblData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert back to table and output
outputTable = array2table(normalMat);
outputTable.Properties.VariableNames = Headers;
end