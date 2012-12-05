
% inputs: queryimage -- the filename of an input query image. databaseDirectory -- the pathname to the image database, queryDirectory -- the pathname to the queries
% outputs: closestmatches -- a cell array with the filenames of the 10 most similar images to the query

% example usage -- [closestMatches] = imageRetrieval_text('img_bags_clutch_1.jpg','/Users/tlberg/Desktop/teaching/Fall_12/hw/hw1/images/','/Users/tlberg/Desktop/teaching/Fall_12/hw/hw1/queryimages/');

function [closestMatches] = imageRetrieval_text(queryimage, databaseDirectory, queryDirectory)

% compute your lexicon here
cd (databaseDirectory);

% Make a hash table of all the stop words
% We got this stop word file from:
% https://github.com/faridani/MatlabNLP/tree/master/nlp%20lib/funcs
fid = fopen('../Stop words.txt');
stopwords = textscan(fid, '%s');
fclose(fid);
stopwords = stopwords{1,:};
stopwords_map = containers.Map('KeyType', 'char', 'ValueType', 'uint64');

for i=1:length(stopwords)
	stopwords{i,:} = strip_punctuation(stopwords{i,:});
    stopwords_map(stopwords{i,:}) = i;
end

% Find all the description files
fileList = dir('*.txt');
j = 1;

% For each description(text) file, do following:
% - read text file
% - read all the words in an array
% - for each word in this array, check if it
%   is present in the stop word hash table.
%   If yes, then do not put it into the lexicon
%   Else, put it in the lexicon
for i=1:length(fileList)
    fileName = fileList(i).name;
    fid = fopen(fileName, 'r');
    words = textscan(fid, '%s');
    words = words{1,:};

    for k = 1:length(words)
        curword = lower(strip_punctuation(strtrim(words{k,:})));
        tempword = regexprep(curword, '[\d]', '');
        if(strcmp(tempword, ''))
            continue;
        end
        
        if(~isKey(stopwords_map, curword))
            lexicon{j, :} = curword;
            j = j + 1;
        end
    end
    
    fclose(fid);
end

% Find out the unique words and then generate
% a hash table for that
lexicon = unique(lexicon);
lexicon_map = containers.Map('KeyType', 'char', 'ValueType', 'uint64');
for j=1:length(lexicon)
    lexicon_map(lexicon{j,:}) = j;
end

% compute word vector descriptors for all database image descriptions here
wordVector = zeros(length(fileList), length(lexicon));

% For all the text files, do following:
% - read text file
% - read all the words in an array
% - for each word in this array, check if it
%   is present in the lexicon hash table.
%   If yes, then increment the value in the
%   corresponding row and column
for i=1:length(fileList)
    fname = fileList(i).name;
    fid = fopen(fname, 'r');
    words = textscan(fid, '%s');
    words = words{1,:};
    
    for k = 1:length(words)
        curword = lower(strip_punctuation(strtrim(words{k,:})));
        tempword = regexprep(curword, '[\d]', '');
        if(strcmp(tempword, ''))
            continue;
        else
            words2{k, :} = curword;
        end
    end
    
    for j=1:length(words2)
        curword = words2{j, :};
        if(isKey(lexicon_map, curword))
            wordVector(i, lexicon_map(curword)) = wordVector(i, lexicon_map(curword)) + 1;
        end
    end
    
    fclose(fid);
end

% compute word vector descriptor for the query image description here
cd(queryDirectory);
queryVector = zeros(1, length(lexicon));

fileName = strcat(strcat('descr_', queryimage(5:length(queryimage)-4)), '.txt');
fid = fopen(fileName, 'r');
words = textscan(fid, '%s');
fclose(fid);
words = words{1,:};

% Similar to above, create a word vector
% for query image using lexicon hash map
for k = 1:length(words)
    curword = lower(strip_punctuation(strtrim(words{k,:})));
    tempword = regexprep(curword, '[\d]', '');
    if(strcmp(tempword, ''))
        continue;
    end

    if(~isKey(stopwords_map, curword))
        if(isKey(lexicon_map, curword))
            queryVector(1, lexicon_map(curword)) = queryVector(1, lexicon_map(curword)) + 1;
        end
    end
end

% compute SSD between the query descriptor and each database image descriptor here
for i=1:length(fileList)
    ssd{i} = sum(sum((queryVector - wordVector(i,:)).^2));
end

% return the 10 closest images to the query here
ssd = cell2mat(ssd);
[~, indices] = sort(ssd);
count = indices(1:10);

for i = 1:length(count)
   closestMatches(i) = fileList(count(i));
   disp(closestMatches(i));
end

return;