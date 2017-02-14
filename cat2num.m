function outVec = cat2num(inVec,posCat,negCat,neutralCat)
% Accepts a cell array input, then search for 2 or 3 strings (positive
% category, negative category, and neutral category). Replaces the category
% string with a 1,-1,0 and converts to matrix

% If only input one category (posCat), then the code will convert all other values
% to {-1} (This is useful for cyto.cat)

if nargin == 2;
    % Convert all items that are not in the positive category to {-1}
    inVec(not(strcmp(inVec,posCat))) = {-1};
    % Convert positive category to 1
    inVec(strcmp(inVec,posCat)) = {1};
elseif nargin > 2;
    % Convert positive category to 1
    inVec(strcmp(inVec,posCat)) = {1};

    % Convert negative category to -1
    inVec(strcmp(inVec,negCat)) = {-1};

    % Convert optional neutral category to 0
    if nargin == 4
        inVec(strcmp(inVec,neutralCat)) = {0};
    end
end

% Converts output to numeric vector
outVec = cell2mat(inVec);
end