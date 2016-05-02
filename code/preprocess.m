function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 
%  Edited by Jeff Wu & Peter Sun

  global DEFINITIONS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [DEFINITIONS.SENTSTART ' ' lower( inSentence ) ' ' DEFINITIONS.SENTEND];

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  outSentence = regexprep(outSentence, '(^|[\s\W])''|''([\s\W]|$)', '${strrep($0, '''''''', '' '''' '')}');
  outSentence = regexprep(outSentence, '[\,\;\:\-\(\)\[\]\{\}\"\+\=\^\%\$\#\@\*\.\?\!]', ' $0 ');

  
 
  switch language
   case 'e'
    outSentence = regexprep(outSentence, '\Sn?''\S', '${[$0(1) '' '' $0(2:end)]}');

   case 'f'
    outSentence = regexprep(outSentence, '(^|\s)l''', '$0 ');
    outSentence = regexprep(outSentence, '(^|\s)(d''(?!abord|accord|ailleurs|habitude)|[^aeioud]'')', '$0 ');
    outSentence = regexprep(outSentence, '(^|\s)qu''', '$0 ');
    outSentence = regexprep(outSentence, '''(on|il)(\s|$)', '${$0(1)} ${$0(2:end)}');

  end

  % trim whitespaces down 
  outSentence = regexprep(outSentence, '\s+', ' ');

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

