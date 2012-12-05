HW1 - Image Retrieval using Visual and Textual Features
-------------------------------------------------------

In this homework you will explore simple image and text features in a retrieval scenario.

Data
Download this shopping data collection shopping.tar.gz. This data contains real shopping images from the web depicting 2 categories (bags and shoes) and text descriptions associated with each image. The images directory contains your database of web images and descriptions, while queryimages contains example query image-description pairs.

Part 1 - Image Feature Based Retrieval (30 pts)

    Write a function that retrieves similar images based on grayscale tiny-image descriptors. Your code should take as input the filename of a query image, directory location of the database, and directory location of the queries. It should return the filenames of the 10 closest images in the database.
    Within your code you should first compute grayscale tiny-image descriptors (image converted to grayscale and resized to icon size of 32x32 pixels) for each image in the database and for the query image. Then you should return the filenames of the 10 most similar images in the database using SSD on your image descriptors. 

Part 2 - Text Feature Based Retrieval (30 pts)

    Write a function that retrieves similar images based on word vector descriptors of their associated textual descriptions. Your code should take as input the filename of a query image, directory location of the database, and directory location of the queries. It should return the filenames of the 10 closest images in the database.
    Within your code you should first compute a lexicon for the database descriptions (you should try variations on lexicons and select the one that produces the best results, e.g. all words observed in any description, commonly occurring words, with stop words removed, and so on). Next you should compute the word vector descriptors for the database descriptions and query image description. Then you should return the filenames of the 10 most similar images in the database using SSD on your text descriptors. 

Part 3 - Combined Text & Image based Retrieval (20 pts)

    Write a function that retrieves images using combined image and text similarity. Your code should take as input the filename of a query image, directory location of the database, and directory location of the queries. It should return the filenames of the 10 closest database images.
    Within your code you should compute the same descriptors as in Parts 1 and 2, calculate SSD based on image descriptors and text descriptors, then combine the two SSD calculations in a weighted sum (alpha*ImageSSD + (1-alpha)*TextSSD). You should play around with possible values for alpha. 

Part 4 - Freestyle (20 pts)

    Implement extensions of your choice. For example, add a different image or text descriptor. Download new query images from the web and see what happens, etc. 

What To Turn In

Submit by email to cse595@gmail.com:

    Your commented code.
    A ReadMe outlining how to run your code and any additional functions included beyond those provided with the assignment.
    A write-up that includes:
        Visualizations for Parts 1, 2, and 3 showing the image-description pairs retrieved for images in the queryimages directory.
        Description of the lexicon you used in Part 2. For full credit, select a lexicon that produces the best results.
        Description and examples of how performance varied as a function of alpha in Part 3. For full credit, select the alpha value that produces the best results.
        Description of where the algorithms worked, where it didn't, and why you think that might be the case. You might want to look past the 10 closest images to get a better sense of how the various algorithms are working.
        Description and results for the extensions you implemented in Part 4. 


Useful Notes

    The most important command in matlab is "help", "help images" will list useful image related functions, and you can get help for particular functions by typing help function name, e.g. "help imagesc" or "help montage".
    The "save" and "load" commands are quite useful to save computation time while debugging code.
    You are welcome to define additional functions that you can call from the high level functions provided with the assignments (so that for example you don't need to repeat code from Parts 1 and 2 in Part 3).