function [trainingMat,responseVar,nanRows] = tblSC(tbl,type,SC)

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
% Record nanRows so they can be dealt with for test data
nanRows = any(isnan(tblData),2);

tblData = tblData(~any(isnan(tblData),2),:);
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
% Normalize the training matrix by the Zscore
trainingMat = zscore(tblData);
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
weight.NPM1 = 1;
weight.NPM1_3542 = 1;
weight.TP53 = 1;
weight.CD34 = 1;
weight.KIT = 1;
weight.CD33 = 1;
weight.ABS_BLST = 1;
weight.BM_BLAST = 1;
weight.BM_MONOCYTES = 1;
weight.PB_BLAST = 1;
weight.BM_PROM = 1;
weight.PB_MONO = 1;
weight.PB_PROM = 1;

% ABS, PBBLAST PB MONO, PB PROM, BM BLast BM MONOCYTESS, BM PROM

% Least important proteins
%weight.ERG = 1;
%weight.HSP90AA1_B1 = 1;
%weight.CBL = 1;

weight = struct2cell(weight);
weight = cell2mat(weight);
weight = weight';

% Multiply the training matrix by the weights
weight = repmat(weight,size(trainingMat,1),1);

trainingMat = trainingMat.*weight;

% Remove zero columns
trainingMat(:,~any(trainingMat)) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end