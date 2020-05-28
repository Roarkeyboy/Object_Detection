% Draws the lines from the scene matches to the object matches (builds off
% match function for drawing)

function draw_new_lines(scene,app,app2,new_db,matches,scale,hObject,handles)
global current_scene;
colour_list = handles.colour_list; % used for dynamic colouring
imagesc(app);axis(handles.axes1, 'equal','tight','off')
scene_path = strcat('input_images/scenes/',current_scene,'.pgm');
scene = imread(scene_path);
cols1 = size(scene,2);
rows2 = size(scene,1);

for kk = 1:matches % iterate all matches
    best_match_loc1 = new_db{kk}(:,1:2); % scene matches
    best_match_loc2 = new_db{kk}(:,3:4); % object matches
    scale_value_y = scale{kk}(:,1); % y scale
    scale_value_x = scale{kk}(:,2); % x scale
    if (kk == 1) % first iteration
        best_match_loc2(:,2) = best_match_loc2(:,2)*scale_value_y;
    else % any other iteration can change scales in rows or cols
        best_match_loc2(:,2) = best_match_loc2(:,2)*scale_value_y;
        best_match_loc2(:,1) = best_match_loc2(:,1)*scale_value_x;
    end 
    if (matches > 2) % scales match locations (for objects) upwards as they are appended to image 
        best_match_loc2(:,2) = best_match_loc2(:,2) * (kk/matches); 
    end
    if (matches == 1) % if one match, row offset is 0
        rows1 = 0;
    elseif(matches >= 2) && (kk == 1) % after matches increase, dont increase rows offset for first match
        rows1 = 0 ;    
    else
        rows1 = ((kk-1)*rows2) / matches; % This sets the offset location for each new match that is added to the image
    end 
    % draw the lines from point to point adding the offsets for cols and
    % rows, also iterates the colour list to find new a new colour per
    % match
    for i = 1: size(best_match_loc1,1)
        line([best_match_loc1(i,1) best_match_loc2(i,1)+cols1], ...
             [best_match_loc1(i,2) best_match_loc2(i,2)+rows1], 'Color', colour_list{kk}(:)/255);
    end
end