
% inputs: queryimage -- the filename of an input query image. databaseDirectory -- the pathname to the image database, queryDirectory -- the pathname to the queries
% outputs: closestMatches -- a cell array with the filenames of the 10 most similar images to the query

% example usage -- [closestMatches] = imageRetrieval_image('img_bags_clutch_1.jpg','/Users/tlberg/Desktop/teaching/Fall_12/hw/hw1/images/','/Users/tlberg/Desktop/teaching/Fall_12/hw/hw1/queryimages/');

function [closestMatches] = imageRetrieval_image(queryimage, databaseDirectory, queryDirectory)

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

% compute SSD between the query image descriptor and each image descriptor in the database here
for i = 1:length(images)
    ssd{i} = sum(sum((tinyQueryImage - images{i}).^2));
end

% return the 10 closest images to the query here
ssd = cell2mat(ssd);
[~, indices] = sort(ssd);

count = indices(1:10);
for i = 1:length(count)
    closestMatches(i) = imageFileList(count(i));
    disp(closestMatches(i));
end

return;
