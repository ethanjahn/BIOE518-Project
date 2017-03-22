function output = marginalPatients(predictions,tolerance)
% Used to find patients which are very difficult to predict outcome for

counter = 0;
for n = 1:numel(predictions)
    if abs(abs(predictions(n)) - 0.5) < tolerance
        counter = counter + 1;
        output(counter) = n;
    end
end

end