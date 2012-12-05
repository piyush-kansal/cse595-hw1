
% inputs: queryimage -- the filename of an input query image. databaseDirectory -- the pathname to the image database, queryDirectory -- the pathname to the queries
% outputs: closestmatches -- a cell array with the filenames of the 10 most similar images to the query

% example usage -- [closestMatches] = imageRetrieval_combined('img_bags_clutch_1.jpg','/Users/tlberg/Desktop/teaching/Fall_12/hw/hw1/images/','/Users/tlberg/Desktop/teaching/Fall_12/hw/hw1/queryimages/');

function [closestMatches] = imageRetrieval_combined(queryimage, databaseDirectory, queryDirectory)

% compute tiny-image descriptors for all database images here
cd(databaseDirectory);

% Find all the images
fileList = dir('*.jpg');

% Then go over all the images and do following:
% - read image file
% - find colortype of image. If it is grayscale
%   then directly resize it else if it is RGB
%   then first convert it to grayscale and then
%   resize it
for i = 1:length(fileList)
    fileName = fileList(i).name;
    imageFileList{i} = fileName;
    currImage = imread(fileName);
    info = imfinfo(fileName);

    if( strcmp(info.ColorType, 'truecolor') )
        images{i} = imresize(rgb2gray(currImage), [32 32]);
    elseif( strcmp(info.ColorType, 'grayscale') )
        images{i} = imresize(currImage, [32 32]);
    end
end

% Remove any empty cells
images = images(~cellfun('isempty',images));

% compute tiny-image descriptor for the query image here
cd (queryDirectory);

% Error check
if(~(exist(queryimage, 'file')))
    disp('Query Image does not exist!!');
    return;
end

% Resize queryimage as well
readQueryImage = imread(queryimage);
info = imfinfo(queryimage);
if(strcmp(info.ColorType, 'truecolor'))
    readQueryImage = rgb2gray(readQueryImage);
end
tinyQueryImage = imresize(readQueryImage, [32 32]);

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

% compute image based SSD and text based SSD values here
% I am varying value of alpha between 0.5 - 0.65. The reason
% of not going beyond 0.65 is that at that moment, more
% weightage is given to image ssds which are not really
% accurate in generating results
for i = 1:length(images)
    img_ssd = sum(sum((tinyQueryImage - images{i}).^2));
    text_ssd = sum(sum((queryVector - wordVector(i,:)).^2));
    
    alpha = 0.5;
    ssd_1{i} = (img_ssd * alpha) + (text_ssd * (1-alpha));

    alpha = 0.15;
    ssd_2{i} = (img_ssd * alpha) + (text_ssd * (1-alpha));

    alpha = 0.25;
    ssd_3{i} = (img_ssd * alpha) + (text_ssd * (1-alpha));

    alpha = 0.35;
    ssd_4{i} = (img_ssd * alpha) + (text_ssd * (1-alpha));

    alpha = 0.45;
    ssd_5{i} = (img_ssd * alpha) + (text_ssd * (1-alpha));

    alpha = 0.65;
    ssd_6{i} = (img_ssd * alpha) + (text_ssd * (1-alpha));
end

% return the 10 closest images to the query here using a weighted sum of SSD values
ssd_1 = cell2mat(ssd_1);
ssd_2 = cell2mat(ssd_2);
ssd_3 = cell2mat(ssd_3);
ssd_4 = cell2mat(ssd_4);
ssd_5 = cell2mat(ssd_5);
ssd_6 = cell2mat(ssd_6);

[~, indices1] = sort(ssd_1);
count = indices1(1:10);
for i = 1:length(count)
    closestMatches(i) = imageFileList(count(i));
    disp(closestMatches(i));
end

[~, indices2] = sort(ssd_2);
count = indices2(1:10);
for i = 1:length(count)
    closestMatches(i) = imageFileList(count(i));
    disp(closestMatches(i));
end

[~, indices3] = sort(ssd_3);
count = indices3(1:10);
for i = 1:length(count)
    closestMatches(i) = imageFileList(count(i));
    disp(closestMatches(i));
end

[~, indices4] = sort(ssd_4);
count = indices4(1:10);
for i = 1:length(count)
    closestMatches(i) = imageFileList(count(i));
    disp(closestMatches(i));
end

[~, indices5] = sort(ssd_5);
count = indices5(1:10);
for i = 1:length(count)
    closestMatches(i) = imageFileList(count(i));
    disp(closestMatches(i));
end

[~, indices6] = sort(ssd_6);
count = indices6(1:10);
for i = 1:length(count)
    closestMatches(i) = imageFileList(count(i));
    disp(closestMatches(i));
end

return;
