function writeToOutput(filename,prediction,subChallengeNum)

% Print confidence to file
outID = fopen(filename,'w');

if subChallengeNum == 1
    fprintf(outID,'#Patient_id,CR_Confidence\n');   
    for i = 1:numel(prediction);
        fprintf(outID,'id_%03i,%.3f\n',i,prediction(i));
    end 
%{
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
    %}
else
    disp('Error: No subchallenge number in writing to file')
end
    
fclose(outID);

end