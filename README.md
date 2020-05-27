# CITS4402 Computer Vision UWA
# Object_Detection project 

Roarke Holland 21742366
Jayden Kur 21988713
Andrew Ha 22246801

# Approach Followed

Data structure -> Coding Process -> SIFT matches -> Appending and lines -> Outlines -> Automation

The implementation uses scale invariant feature transformation (SIFT) to match objects with scenes
that include (or dont) these objects. Firstly 20 objects were chosen and then photographed from
approximately 6 to 9 different angles or orientations. After this the file structure was developed 
full_size_images which includes all the high resolution images and input_images which were the converted images
that would be passed into the computational parts of the program. 

The coding process started with developing a GUI that would assist in converting images to pgm files as 
pgm files are passed into the given SIFT function. The GUI would also be able to save their SIFT data (descriptors and locations)
of each image to a matlab file which can be accessed later to greatly save time in processing. The GUI would also serve as a 
demonstration of the SIFT functions and how the automated process would look. The team also implemented a RANSAC method which was 
based on an online application in order to remove outliers.

After retreiving the sift data, a way of appending images vertically was designed to append the matches that were found in a scene.
Then after appending, our group developed a way to translate the match locations of an object to where the object had been appened alongside the scene. 
The object detector needed to compute or show the outlines of the given objects around the object it had detected in the
scene even when occluded. The group then designed a geometric transformation function that is able to transform the match
positions on an object to where they are in the scene. 

This process was helped with an online function related to creating an image mosaic which essentially transforms the object and creates a new image that
is the size of the scene object to accurately display it over the scene image. Our application adds a canny edge detector which gets the
out line of the object in question for later use. In conjunction with this, another function was developed to
take the canny image from the previous function and when converted to binary, can set the pixels that are '1' to a colour that is chosen
dynamically for how many matches there are. This results in a scene image which has had its pixels replaced at certain coordinates to outline an 
object.

After this was all completed the next GUI was created and the other functions were used together to make an automated process where a scene is loaded in and
objects are detected automatically with their matches being drawn onto the scene and their names being appended to a list box on the GUI. As well as an
accuracy for the object detector analyzing that scene. 


# Details of Folders ( '-' indicates folder depth)

(folders)
Object_Detection
* full_size_images
  * objects (all objects are in individually named folders with jpg images inside the folders) 
    * bandaids
    * etc....
  * scenes (all 30 scenes as jpgs in this folder labelled scene_1, - > ,scene_30)
* input_images
  * objects (all objects are in individually named folders with jpg, pgm and mat data inside their folders) 
  * scenes (all 30 scenes as pgm and mat data in this folder labelled scene_1, - > ,scene_30)

(relevant matlab code files)
1. appendimages
2. appendimages2
3. dilate_them
4. draw_new_lines
5. findHomography
6. full_run
7. GUI_testing
8. GUI_testing (figure)
9. match
10. new_match
11. object_recognition
12. object_recognition (figure)
13. randIndex
14. ransac_match
15. ransac1
16. showkeys
17.sift
18. solveHomo
19. warp_it

# Procedure to Run Code


Firstly copy all of the folders to a location and make sure computer vision toolbox is installed due to some uses of the 
inbuilt function (such as estimategeometrictransformation).

Open then run GUI_testing file (either the figure or matlab file). This file is used as a demonstrations of what functions will be used
in the automated process. The left two buttons (read folder, convert to pgm, and save all SIFT data) are used only if new data is added
and were used in the process of designing the current system so they currently just overwrite the current data.
The buttons in the middle section underneath SIFT matching demonstrate the SIFT functions applied to the data as well as the RANSAC
function to remove outliers.
On the right there are 2 buttons to demonstrate the append and match function in colour which the automated system uses. Underneath
that is a button (draw outline) that draws a canny edge detected outline around the object detected in the scene, also used in the main 
system.

Open then run Object_detection file (either the figure or matlab file). This file demonstrates the automated process of detecting objects in a scene.
First load in a scene from the folder that is loaded by the button (scene_1 to scene_30). Unticking "Use Trained Model" causes the runtime function to 
run sift matches on all objects in the the input_images -> objects folder as well as the current scene. For the sake of time
it is recommended that the box is left ticked as the model is already "trained" with the SIFT data. 
After a scene is loaded select the "Detect Trained Objects" button to begin the search for objects in that chosen scene. The axes object is updated
in real time with objects found as well as drawing the outline and lines connecting scene matches to object matches. After the search has completed the status
bar on the left will be green indicating it is finished searching and the list of objects will have been appened as they were when they were discovered. 
The accuracy of the scene (objects trained/objects found) will be shown at the bottom of the figure after the search is complete.
In addition to this, there is two checkboxes which can be ticked/unticked to show lines or matches only after the search has completed.

