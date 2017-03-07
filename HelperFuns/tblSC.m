function [trainingMat,responseVar,nanRows,Headers] = tblSC(tbl,type,SC)

% Add additional features as necessary
tbl.BM_ABS_RATIO = tbl.BM_BLAST ./ tbl.ABS_BLST;
tbl.BM_ABS_RATIO(tbl.BM_ABS_RATIO == Inf) = 0;
tbl.BM_ABS_RATIO(isnan(tbl.BM_ABS_RATIO)) = 0;

% Remove training data that is irrelevant depending on subchallenge
if strcmp(type,'train')
    if SC == 1
        responseCol = 'resp_simple';
        %remove columns that are irrelevant for SC1
        tbl.Overall_Survival = [];
        tbl.vital_status = [];
        tbl.Remission_Duration = [];
    elseif SC == 2
        responseCol = 'Remission_Duration';
        %remoce columns that are irrelevant for SC2
        tbl.resp_simple = [];
        tbl.vital_status = [];
        tbl.Overall_Survival = [];
    elseif SC == 3
        responseCol = 'Overall_Survival';
        %remove columns that are irrelevant for SC3
        tbl.resp_simple = [];
        tbl.vital_status = [];
        tbl.Remission_Duration = [];
    else
        disp('Error: Subchallenge not specified correctly')
    end
end

% Convert table to array and header vector
tblData = table2array(tbl);
Headers = tbl.Properties.VariableNames;

%%%%%%%%%%%%% Remove NaN %%%%%%%%%%%%%%%%%%%%
if SC == 1
    % Change NaN values to the mean of the column they are in
    %tblData = changeNaN(tblData);
    
    % Record nanRows so they can be dealt with for test data
    nanRows = any(isnan(tblData),2);
elseif (SC == 2 || SC == 3) && strcmp(type,'train')
    % Record nanRows so they can be dealt with for test data
    nanRows = any(isnan(tblData),2);
    
    disp('Fix removing NaN in the response var for SC2 and 3')
    %{
    %%% TODO %%%
    % Remove rows with NaN in the response var
    tblData(
    %}
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(type,'train')
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
trainingMat = nanzscore(tblData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%% WEIGHTING %%%%%%%%%%%%%%%%%%%
% Create a weighting struct
for i = 1:size(tblData,2)
    weight.(Headers{i}) = 0;
end

weight.cyto_cat_score = 1;
weight.PRIOR_MAL = 1;
weight.ITD = 1;
weight.D835 = 1;
weight.Age_at_Dx = 1;
weight.WBC = 1;
% New 
weight.BM_MONOCYTES = 1;
weight.PB_BLAST = 1;
weight.PB_MONO = 1;
weight.BM_ABS_RATIO = 1;

weight = struct2cell(weight);
weight = cell2mat(weight);
weight = weight';

% Multiply the training matrix by the weights
weight = repmat(weight,size(trainingMat,1),1);
trainingMat = trainingMat.*weight;

% Remove zero columns
Headers(~any(trainingMat)) = [];
trainingMat(:,~any(trainingMat)) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end