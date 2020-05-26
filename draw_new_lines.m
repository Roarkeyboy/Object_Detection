% Draws the lines from the scene matches to the object matches
function draw_new_lines(scene,app,app2,new_db,matches,scale,hObject,handles)
global current_scene;
colour_list = handles.colour_list;
imagesc(app);axis(handles.axes1, 'equal','tight','off')

scene_path = strcat('input_images/scenes/',current_scene,'.pgm');
scene = imread(scene_path);

rows1 = 0;
cols1 = size(scene,2);
rows2 = size(scene,1);

for kk = 1:matches
    best_match_loc1 = new_db{kk}(:,1:2); % scene matches
    best_match_loc2 = new_db{kk}(:,3:4); % object matches
    scale_value_x = scale{kk}(:,1); % x scale
    scale_value_y = scale{kk}(:,2); % y scale
    if (kk > 1)
        disp(scale_value_x)
        disp(scale_value_y)
        if (scale_value_x < scale{1}(:,1))   
            best_match_loc2(:,1) = best_match_loc2(:,1).*scale_value_x;
        else
            best_match_loc2(:,1) = best_match_loc2(:,1)./scale_value_x;
        end
        if (scale_value_y < scale{1}(:,2)) 
            best_match_loc2(:,2) = best_match_loc2(:,2).*scale_value_y;
        else
            best_match_loc2(:,2) = best_match_loc2(:,2)./scale_value_y;
        end
    end   
    if (((matches == 1) ||(matches == 2)) && ((kk == 2) || (kk == 1)))
        best_match_loc2 = best_match_loc2;
        %best_match_loc2(:,2) = best_match_loc2(:,2)/(matches);
    else
        %best_match_loc2 = best_match_loc2/(matches);
        best_match_loc2(:,2) = best_match_loc2(:,2)/(matches-1.5);
       % best_match_loc2(2,:) = best_match_loc2(2,:);   
    end
    if (matches == 1)
        rows1 = 0;
    elseif(matches > 2) && (kk == 1)
        rows1 = 0 ;     
    else
        rows1 = ((kk-1)*rows2) / matches;
    end 
    for i = 1: size(best_match_loc1,1)
        line([best_match_loc1(i,1) best_match_loc2(i,1)+cols1], ...
             [best_match_loc1(i,2) best_match_loc2(i,2)+rows1], 'Color', colour_list{kk}(:)/255);
    end
end