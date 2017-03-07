function output = marginalPatients(predictions,tolerance)

counter = 0;
for n = 1:numel(predictions)
    if abs(abs(predictions(n)) - 0.5) < tolerance
        counter = counter + 1;
        output(counter) = n;
    end
end

end