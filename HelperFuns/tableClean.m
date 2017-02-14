function outTable = tableClean(inTable,type)

% Convert categorical data to numeric
inTable.SEX = cat2num(inTable.SEX,'F','M');
inTable.PRIOR_MAL = cat2num(inTable.PRIOR_MAL,'YES','NO');
inTable.PRIOR_CHEMO = cat2num(inTable.PRIOR_CHEMO,'YES','NO');
inTable.PRIOR_XRT = cat2num(inTable.PRIOR_XRT,'YES','NO');
inTable.Infection = cat2num(inTable.Infection,'Yes','No');
inTable.ITD = cat2num(inTable.ITD,'POS','NEG','ND');
inTable.D835 = cat2num(inTable.D835,'POS','NEG','ND');
inTable.Ras_Stat = cat2num(inTable.Ras_Stat,'POS','NEG','NotDone');

if strcmp(type,'train')
    inTable.vital_status = cat2num(inTable.vital_status,'A','D');
    inTable.resp_simple = cat2num(inTable.resp_simple,'CR','RESISTANT');
elseif strcmp(type,'test')
else
    disp('Error: Invalid type of table')
end

% Get only the numericValues (eventually would need to put everything into
% numeric)
outTable = numericOnly(inTable,type);

end