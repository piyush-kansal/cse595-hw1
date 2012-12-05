function str = strip_punctuation(str)

% strip_punctuation - strip punctuation from string
% -------------------------------------------------
% 
% str = strip_punctuation(str);
%
% Input:
% ------
%  str - input string
% 
% Output:
% -------
%  str - output string

%--------------------------------
% Author: Harold Figueroa
%--------------------------------
% $Revision: 4409 $
% $Date: 2006-03-28 19:30:39 -0500 (Tue, 28 Mar 2006) $
%--------------------------------

% TODO: implement this using regular expressions

%--
% create array of punctuation
%--

punct = double(['`~!@#$%^&*()-=+[{]}\|;:''",<.>/?']);

%--
% remove punctuation from string
%--

str = double(str);

for k = 1:length(punct)
	ix = find(str == punct(k)); str(ix) = [];
end

str = char(str);

%--
% convert spaces to underscore
%--

% TODO: check whether this is used by calling functions, it does not fit semantics

str = strrep(str,' ','_');
