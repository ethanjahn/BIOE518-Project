% Custom code for genetic algorithm:
% 1. The number of weighting params are given, as well as the
% fitness function.
%
% 2. The code creates an initial population (nPop) of random weightings
%
% 3. Each random weighting is evaluated by fitnessFcn
%
% 4. The top (nSurvive) weightings are allowed to breed
%
% 5. The nSurvive weightings are randomly combined to generate a new nPop
%
% 6. The new generation is randomly perturbed before being evaluated by
% fitnessFcn (degree of perturbation determined by (mutagen))
%
% 7. A running tally of the top scores (nTop) is generated
%
% 8. The ga stops after (nGen) generations

function genOpt(fitnessFcn,nWeight,nPop,nSurvive,mutagen,nGen)
% Part 1: Generate nPop random weightings
initPop = rand(nPop,nWeight);

%{
% Part 2: Scoring top weightings
for i = 1:size(initPop,1))
    currentWeight = initPop(i,:);
    CurrentScore(i) = fitnessFcn(currentWeight);
    
    if CurrentScore(i) > worstTopScore
        scoreBoard = scor
end
%}




end


function optWeights = breed(initWeights,fitnessfun)




end