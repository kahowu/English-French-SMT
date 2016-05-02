function out = convertSymbols(in)
%
%  convertSymbols
%
%  This function converts [symbols that cannot be used in 
%  Matlab's dictionary as keys] to [special words that can].
%
%

DEFINITIONS

out = in;

out = regexprep(out, '\*', DEFINITIONS.STAR);
out = regexprep(out, '\-', DEFINITIONS.DASH);
out = regexprep(out, '\+', DEFINITIONS.PLUS);
out = regexprep(out, '\=', DEFINITIONS.EQUALS);
out = regexprep(out, '\,', DEFINITIONS.COMMA);
out = regexprep(out, '\.', DEFINITIONS.PERIOD);
out = regexprep(out, '\?', DEFINITIONS.QUESTION);
out = regexprep(out, '\!', DEFINITIONS.EXCLAM);
out = regexprep(out, ':', DEFINITIONS.COLON);
out = regexprep(out, ';', DEFINITIONS.SEMICOLON);
out = regexprep(out, '''', DEFINITIONS.SINGQUOTE);
out = regexprep(out, '"', DEFINITIONS.DOUBQUOTE);
out = regexprep(out, '`', DEFINITIONS.BACKQUOTE);
out = regexprep(out, '\(', DEFINITIONS.OPENPAREN);
out = regexprep(out, '\)', DEFINITIONS.CLOSEPAREN);
out = regexprep(out, '\[', DEFINITIONS.OPENBRACK);
out = regexprep(out, '\]', DEFINITIONS.CLOSEBRACK);
out = regexprep(out, '/', DEFINITIONS.SLASH);
out = regexprep(out, '\$', DEFINITIONS.DOLLAR);
out = regexprep(out, '\%', DEFINITIONS.PERCENT);
out = regexprep(out, '\&', DEFINITIONS.AMPERSAND);
out = regexprep(out, '<', DEFINITIONS.LESS);
out = regexprep(out, '>', DEFINITIONS.GREATER);
out = regexprep(out, '^(\d)', 'N$1');  % leading digit only
out = regexprep(out, '\s(\d)', ' N$1');  % leading digit only

return