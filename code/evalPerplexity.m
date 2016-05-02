% Edited by Jeff Wu 

function ps = evalPerplexity (language)

deltas = [0.01, 0.05, 0.1, 0.5, 0.75, 1];
ps = [];
model_name = strcat(strcat ('../train_', language), '_LM.mat');
load (model_name);

% No smoothing 
ps_ns = perplexity (LM, '../data/Hansard/Testing/', language, '', 0);
ps = [ps ps_ns];

% Delta smoothing
for i=1:length(deltas)
    p = perplexity (LM, '../data/Hansard/Testing/', language, 'smooth', deltas(i));
    ps = [ps p];
end

disp (ps);

return;