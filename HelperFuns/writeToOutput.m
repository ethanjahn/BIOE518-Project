function writeToOutput(filename,prediction,nanRows,defaultValue,subChallengeNum)

% Create confidence vector
confidence = ones(size(nanRows,1),1);
confidence = confidence.*defaultValue;
confidence(~nanRows) = prediction;
confidence(confidence == -1) = 0;

% Print confidence to file
outID = fopen(filename,'w');

if subChallengeNum == 1
    fprintf(outID,'#Patient_id,CR_Confidence\n');   
    for i = 1:numel(confidence);
        fprintf(outID,'id_%03i,%.1f\n',i,confidence(i));
    end 
elseif subChallengeNum == 2
    fprintf(outID,'#Patient_id,Remission_Duration,Confidence\n');
    for i = 1:numel(confidence);
        fprintf(outID,'id_%03i,%.1f,1\n',i,confidence(i));
    end
elseif subChallengeNum == 3
    fprintf(outID,'#Patient_id,Overall_Survival,Confidence\n');
    for i = 1:numel(confidence);
        fprintf(outID,'id_%03i,%.1f,1\n',i,confidence(i));
    end
else
    disp('Error: No subchallenge number in writing to file')
end
    
fclose(outID);

end