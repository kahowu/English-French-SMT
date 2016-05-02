function AM = align_ibm1 (trainDir, numSentences, maxIter, fn_AM)
    %
    %  align_ibm1
    % 
    %  This function implements the training of the IBM-1 word alignment algorithm. 
    %  We assume that we are implementing P(foreign|english)
    %
    %  INPUTS:
    %
    %       dataDir      : (directory name) The top-level directory containing 
    %                                       data from which to train or decode
    %                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
    %       numSentences : (integer) The maximum number of training sentences to
    %                                consider. 
    %       maxIter      : (integer) The maximum number of iterations of the EM 
    %                                algorithm.
    %       fn_AM        : (filename) the location to save the alignment model,
    %                                 once trained.
    %
    %  OUTPUT:
    %       AM           : (variable) a specialized alignment model structure
    %
    %
    %  The file fn_AM must contain the data structure called 'AM', which is a 
    %  structure of structures where AM.(english_word).(foreign_word) is the
    %  computed expectation that foreign_word is produced by english_word
    %
    %       e.g., LM.house.maison = 0.5       % TODO
    % 
    % Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
    % Edited by Jeff Wu & Peter Sun

    global DEFINITIONS

    AM = struct();

    % Read in the training data
    [eng, fre] = read_hansard(trainDir, numSentences);

    % Initialize AM uniformly 
    tic;
    AM = initialize(eng, fre);
    toc;
    % Iterate between E and M steps
    for iter=1:maxIter,
        display (iter, 'Iteration')
        AM = em_step(AM, eng, fre);
    end
    
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;
    
%     Save the alignment model
    save( fn_AM, 'AM', '-mat'); 

end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
    eng = {};
    fre = {};
    sent_count = 0; 
    english_DD = dir( [mydir, filesep, '*', 'e'] );
    french_DD = dir( [mydir, filesep, '*', 'f'] );

    for iFile = 1:length(english_DD)
        e_lines = textread([mydir, filesep, english_DD(iFile).name], '%s','delimiter','\n');
        f_lines = textread([mydir, filesep, french_DD(iFile).name], '%s','delimiter','\n');
        file_length = length (e_lines); 
        for l=1:file_length
            if sent_count < numSentences
                e_line = strsplit(' ', preprocess(e_lines{l}, 'e'));
                f_line = strsplit(' ', preprocess(f_lines{l}, 'e'));
                eng{sent_count + 1} = e_line;
                fre{sent_count + 1} = f_line;
                sent_count = sent_count + 1; 
            else 
                break
            end
        end

        if sent_count == numSentences
            break
        end
    end
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = struct();
    cell_len = length (eng);
    for l=1:cell_len
        e_words = eng{l};
        f_words  = fre{l};
        e_len = length (e_words);
        f_len = length (f_words);
        for e=1:e_len
            e_word = char(e_words(e));
            if ~isfield (AM, (e_word))
                AM.(e_word)= struct();
            end
            for f=1:f_len
                f_word = char(f_words(f));
                if ~isfield (AM.(e_word), (f_word))
                    AM.(e_word).(f_word) = 0; 
                end
            end
        end
    end 
    
    eng_words = fieldnames(AM);
    e_length = length (eng_words);
    for i=1:e_length
        e_word = char(eng_words(i));
        f_fields = fieldnames(AM.(e_word));
        f_length = length(f_fields); 
        prob = 1 / f_length;
        for f=1:f_length
            f_word = char(f_fields(f));
            AM.(e_word).(f_word) = prob;
        end
    end
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
    cell_len = length (eng);
    e_fields = fieldnames (t);
    total_e = struct();
    count = struct();
    e_field_length = length (e_fields);

    for e = 1:e_field_length
        e_word = char(e_fields (e)); 
        total_e.(e_word) = 0;

        f_fields = fieldnames(t.(e_word));
        f_field_length = length(f_fields); 
        count.(e_word) = struct();

        for f=1:f_field_length
            f_word = char(f_fields(f));
            count.(e_word).(f_word) = 0;
        end
    end
    
    for l=1:cell_len
        e_words = eng{l};
        f_words = fre{l}; 
        e_length = length (e_words); 
        f_length = length (f_words);
        s_total_f = struct();
        
        for f=1:f_length
            f_word = char(f_words(f)); 
            s_total_f.(f_word) = 0;
            f_count = sum (ismember(f_words, f_word));
            for e=1:e_length
                e_word = char(e_words(e));
                s_total_f.(f_word) = s_total_f.(f_word) + t.(e_word).(f_word) * f_count;
            end
            
            tf = s_total_f.(f_word);
            for e=1:e_length
                e_word = char(e_words(e));
                e_count = sum (ismember(e_words, e_word));
                tfe = t.(e_word).(f_word);
                delta = ((tfe * e_count * f_count) / tf);
                count.(e_word).(f_word) = count.(e_word).(f_word) + delta;
                total_e.(e_word) = total_e.(e_word) + delta;   
            end
        end
    end  
  
    for e = 1:e_field_length
        e_word = char(e_fields (e)); 
        f_fields = fieldnames(t.(e_word));
        f_field_length = length(f_fields); 
        for f=1:f_field_length
            f_word = char(f_fields(f));
            t.(e_word).(f_word) = count.(e_word).(f_word) / total_e.(e_word);
        end
    end
end
