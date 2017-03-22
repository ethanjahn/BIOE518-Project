function writeToOutput(filename,prediction)

% Print confidence to file
outID = fopen(filename,'w');

fprintf(outID,'#Patient_id,CR_Confidence\n');

for i = 1:numel(prediction);
    fprintf(outID,'id_%03i,%.3f\n',i,prediction(i));
end

fclose(outID);

end