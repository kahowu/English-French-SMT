function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz
% Edited by Jeff Wu & Peter Sun

logProb = -Inf;

% some rudimentary parameter checking
if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
end
if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
elseif strcmp(type, 'smooth')
    if (nargin < 5)  
        disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
        return;
    end
    if (delta <= 0) or (delta > 1.0)
        disp( 'lm_prob: you must specify 0 < delta <= 1.0');
        return;
    end
else
    disp( 'type must be either '''' or ''smooth''' );
    return;
end

words = strsplit(' ', sentence);

% vocabSize = length(fieldnames(LM.uni));

% TODO: the student implements the following
probs = [];
if isempty (type)
    for index = 1:length (words) - 1
        word = words {index}; 
        if index ~= length (words) 
            next_word = words{index + 1}; 
            if ~isfield(LM.uni, (word))
                probs = [probs 0];
                continue;
            else
                if ~isfield(LM.bi.(word), (next_word))
                    current_uni = LM.uni.(word); 
                    current_bi = 0; 
                else
                    current_uni = LM.uni.(word); 
                    current_bi = LM.bi.(word).(next_word); 
                end
            end          
            p_cond = current_bi / current_uni; 
            probs = [probs p_cond];
        end
    end
else
    for index = 1:length (words) - 1
        word = words {index}; 
        if index ~= length (words)
            next_word = words{index + 1};
            if ~isfield(LM.uni, (word))
                current_uni = delta * vocabSize;
                current_bi = delta;
            else
                if ~isfield(LM.bi.(word), (next_word))
                    current_uni = LM.uni.(word) + delta * vocabSize; 
                    current_bi = delta;
                else
                    current_uni = LM.uni.(word) + delta * vocabSize;  
                    current_bi = LM.bi.(word).(next_word) + delta; 
                end
            end          
            p_cond = current_bi / current_uni; 
            probs = [probs p_cond];
        end
    end 
end

logProb = log2(prod (probs));
% TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.

return;