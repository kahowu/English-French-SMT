function LM = lm_train(dataDir, language, fn_LM)
%
%  lm_train
% 
%  This function reads data from dataDir, computes unigram and bigram counts,
%  and writes the result to fn_LM
%
%  INPUTS:
%
%       dataDir     : (directory name) The top-level directory containing 
%                                      data from which to train or decode
%                                      e.g., '/u/cs401/A2_SMT/data/Toy/'
%       language    : (string) either 'e' for English or 'f' for French
%       fn_LM       : (filename) the location to save the language model,
%                                once trained
%  OUTPUT:
%
%       LM          : (variable) a specialized language model structure  
%
%  The file fn_LM must contain the data structure called 'LM', 
%  which is a structure having two fields: 'uni' and 'bi', each of which holds
%  sub-structures which incorporate unigram or bigram COUNTS,
%
%       e.g., LM.uni.word = 5       % the word 'word' appears 5 times
%             LM.bi.word.bird = 2   % the bigram 'word bird' appears twice
% 
% Template (c) 2011 Frank Rudzicz
%  Edited by Jeff Wu & Peter Sun


global DEFINITIONS

LM=struct();
LM.uni = struct();
LM.bi = struct();

SENTSTARTMARK = 'SENTSTART'; 
SENTENDMARK = 'SENTEND';

DD = dir( [ dataDir, filesep, '*', language] );

disp([ dataDir, filesep, '.*', language] );

for iFile=1:length(DD)

    lines = textread([dataDir, filesep, DD(iFile).name], '%s','delimiter','\n');

    for l=1:length(lines)
        % lines{l}

        processedLine =  preprocess(lines{l}, language);
        words = strsplit(' ', processedLine );
    
        % TODO: THE STUDENT IMPLEMENTS THE FOLLOWING
	    for index=1:length (words)
            word = words{index};
            if ~strcmp (word, '')
                % New entry
                if ~isfield(LM.uni, (word))
                    LM.uni.(word) = 1;
                    LM.bi.(word) = struct();
                    if index ~= length (words)
                        next_word = words{index + 1};
                        LM.bi.(word).(next_word) = 1;
                    end
            % Existing entry
            else
                LM.uni.(word) = LM.uni.(word) + 1;
                if index ~= length (words)
                    next_word = words{index + 1};
                    % next_word
                    if ~isfield (LM.bi.(word), (next_word))
                    	LM.bi.(word).(next_word) = 1;
                    else
                    	LM.bi.(word).(next_word) = LM.bi.(word).(next_word) + 1;
                    end
                end
            end
        % TODO: THE STUDENT IMPLEMENTED THE PRECEDING
        end
    end
end
end

save( fn_LM, 'LM', '-mat'); 