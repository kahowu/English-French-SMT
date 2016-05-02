% Edited by Jeff Wu & Peter Sun
%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5.
clear

% some of your definitions
% trainDir     = TODO;
% testDir      = TODO;
% fn_LME       = TODO;
% fn_LMF       = TODO;
% lm_type      = TODO;
% delta        = TODO;
% vocabSize    = TODO; 
% numSentences = TODO;

% Train your language models. This is task 2 which makes use of task 1
% LME = lm_train( trainDir, 'e', fn_LME );
% LMF = lm_train( trainDir, 'f', fn_LMF );

% Train your alignment model of French, given English 
% AMFE = align_ibm1( trainDir, numSentences );
% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this

% process candidate sentences
%{
candidateAmSizes = {'1'; '10'; '15'; '30'};
delta = 0.75;
load('models/train_e_LM.mat')
for i = 1:length(candidateAmSizes)
    load(['models/train_' candidateAmSizes{i} 'k_AM.mat']);
    lines = textread('data/Hansard/Testing/Task5.f', '%s','delimiter','\n');
    file = fopen(['output/Task5_' candidateAmSizes{i} 'kAM_' strrep(num2str(delta), '.', 'p') '_processed_candidate.e'], 'w');
    for l=1:length(lines)
        fre = preprocess(lines{l}, 'f');
        % Remove SENTSTART and SENTEND
        fre = fre(11:end-8);
        % Decode the test sentence 'fre'
        eng = decode2( fre, LM, AM, 'smooth', delta, length(fieldnames(LM.uni)) );
        fprintf(file, '%s\n', eng);
    end
    fclose(file);
end
%}



% process reference sentences
%{
lines = textread('data/Hansard/Testing/Task5.e', '%s','delimiter','\n');
file = fopen('data/Hansard/Testing/Task5_original_processed_reference.e', 'w');
for l=1:length(lines)
    eng = preprocess(lines{l}, 'e');
    % Remove SENTSTART and SENTEND
    eng = eng(11:end-8);
    % Decode the test sentence 'fre'
    fprintf(file, '%s\n', eng);
end
fclose(file);
%}




% BLEU score calculation starts here
%
references = {
    'output/Task5_original_processed_reference.e';
    'output/Task5_google_processed_reference.e';
    'output/Task5_bluemix_processed_reference.e'
};

candidateAmSizes = {'1'; '10'; '15'; '30'};
delta = '0p75';

referencesLines = [];
for i = 1:length(references)
    lines = textread(references{i}, '%s','delimiter','\n');
    referencesLines = [referencesLines lines];
end

candidatesLines = [];
for i = 1:length(candidateAmSizes)
    file = ['output/Task5_' candidateAmSizes{i} 'kAM_' delta '_processed_candidate.e'];
    lines = textread(file, '%s','delimiter','\n');
    candidatesLines = [candidatesLines lines];
end

n = 3
numSents = 25;
avgBLEU = zeros(length(candidateAmSizes), n);

for i = 1:numSents
    disp(['Sentence: ' num2str(i)]);
    
    uni = struct();
    bi = struct();
    tri = struct();
    lengths = [];

    % references
    for j = 1:length(references)
        words = strsplit(' ', char(referencesLines(i, j)));
        lengths = [lengths length(words)];
        for index = 1:length(words)
            word = words{index};
            if ~strcmp (word, '')
                % uni-gram
                uni.(word) = 1;
                if index ~= length (words)
                    % bi-gram
                    if ~isfield(bi, word)
                        bi.(word) = struct();
                    end
                    nextWord = words{index + 1};
                    bi.(word).(nextWord) = 1 ;
                    if index ~= length (words) - 1
                        % tri-gram
                        if ~isfield(tri, word)
                            tri.(word) = struct();
                        end
                        if ~isfield(tri.(word), nextWord)
                            tri.(word).(nextWord) = struct();
                        end
                        nextNextWord = words{index + 2};
                        tri.(word).(nextWord).(nextNextWord) = 1;
                    end
                end
            end
        end
    end

    % candidates
    for j = 1:length(candidateAmSizes)
        words = strsplit(' ', char(candidatesLines(i, j)));
        % n-gram precision
        N1 = length(words);
        N2 = N1 - 1;
        N3 = N2 - 1;
        C1 = 0;
        C2 = 0;
        C3 = 0;
        for index = 1:length(words)
            word = words{index};
            if ~strcmp (word, '')
                % uni
                if isfield(uni, word)
                    C1 = C1 + 1;
                end
                if index ~= length(words)
                    % bi
                    nextWord = words{index + 1};
                    if isfield(bi, word) && isfield(bi.(word), nextWord)
                        C2 = C2 + 1;
                    end
                    if index ~= length(words) - 1
                        % tri
                        nextNextWord = words{index + 2};
                        if isfield(tri, word) && isfield(tri.(word), nextWord) && isfield(tri.(word).(nextWord), nextNextWord)
                            C3 = C3 + 1;
                        end
                    end
                end
            end
        end
%         disp([num2str(C1) '/' num2str(N1)]);
%         disp([num2str(C2) '/' num2str(N2)]);
%         disp([num2str(C3) '/' num2str(N3)]);


        % brevity penality
        c = length(words);
        nearestRef = 1;
        for k = 2:length(lengths)
            if (abs(lengths(k) - c) < abs(lengths(nearestRef) - c))
                nearestRef = k;
            end
        end
        r = lengths(nearestRef);
        brevity = r / c;
        BP = 1;
        if brevity >= 1
            BP = exp(1 - brevity);
        end

        % BLEU score
        p = [C1 / N1; C2 / N2; C3 / N3];
        BLEU = [];
        for k = 1:n
            BLEU = [BLEU (BP * prod(p(1:k)) ^ (1 / k))];
        end
        disp(BLEU);
        avgBLEU(j, :) = avgBLEU(j, :) + BLEU;
    end

end


avgBLEU = avgBLEU / numSents
%}




% TODO: perform some analysis
% add BlueMix code here
%{
key = 'a824ecb8-794f-4dd8-9f86-b758107c2a01:q4Nxcc5Dj4U1';
lines = textread('../data/Hansard/Testing/Task5.f', '%s','delimiter','\n');
file = fopen('../data/Hansard/Testing/Task5.bluemix.e', 'w');
for l=1:length(lines)
    cmd = ['env LD_LIBRARY_PATH='''' curl -u ' key ' -X POST -F "text=' lines{l} '" -F "source=fr" -F "target=en" "https://gateway.watsonplatform.net/language-translation/api/v2/translate"'];
    [status, result] = unix(cmd);
    result
    fprintf(file, '%s\n', result);
end
fclose(file);
%}