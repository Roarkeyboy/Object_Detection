function draw_new_lines(scene,app,app2,new_db,matches,scale,hObject,handles)
global current_scene;
colour_list = ['b','g','r','c','m','y','k','w','Brown','PaleYellow','Gray','Orange'];

imagesc(app);axis(handles.axes1, 'equal','tight','off')

scene_path = strcat('found_objects/',current_scene,'/',current_scene,'.pgm');
scene = imread(scene_path);

rows1 = 0;
cols1 = size(scene,2);
rows2 = size(scene,1);

% app2_path = strcat('found_objects/',current_scene,'/append_',num2str(matches),'.pgm');
% app2 = imread(app2_path);

%cols3 = size(app2,2);
%rows3 = size(app2,1);

%segment = imcrop(app2,[0,0,300,300]);
%new_match(scene_path,app2_path,1);

% [match_loc1, match_loc2] = new_match(scene_path,app2_path,0);
% [H, corrPtIdx] = findHomography(match_loc2',match_loc1');
% [match_loc1,match_loc2,num] = ransac_match(scene_path,app2_path,corrPtIdx,0);

% for kk = 1:matches
%     app2_path = strcat('found_objects/',current_scene,'/append_',num2str(matches),'.pgm');
%     app2 = imread(app2_path);
%     if (matches > 1)
%         cols3 = size(app2,2);
%         rows3 = size(app2,1);
%         %segment = imcrop(app2,[0,0+(kk-1)*rows3,cols3,matches*(rows3/2)]);
%         segment = imcrop(app2,[0, 0+(kk-1)*(rows3/matches), cols3, rows3/matches]);
%         new_app2 = zeros(cols3,rows3);
%         imshow(new_app2);
%         new_app2(1,1+(kk-1)*(rows3/matches),:) = segment;
%         
%         imshow(new_app2)
% 
% 
%         
%         %imwrite(segment,strcat('found_objects/',current_scene,'/segment_',num2str(matches),'.pgm'),'pgm');
%     end
%     [match_loc1, match_loc2] = new_match(scene_path,app2_path,0);
%     [~, corrPtIdx] = findHomography(match_loc2',match_loc1');
%     [match_loc1,match_loc2,~] = ransac_match(scene_path,app2_path,corrPtIdx,0);
%     
%     for i = 1: size(match_loc1,1)
%         line([match_loc1(i,1) match_loc2(i,1)+cols1], ...
%              [match_loc1(i,2) match_loc2(i,2)], 'Color', colour_list(kk));
%     end
% end

for kk = 1:matches
    best_match_loc1 = new_db{kk}(:,1:2); % scene matches
    best_match_loc2 = new_db{kk}(:,3:4); % object matches
    scale_value_x = scale{kk}(:,1);
    scale_value_y = scale{kk}(:,2);
    if (scale_value_x < scale{1}(:,1))   
        best_match_loc2(:,1) = best_match_loc2(:,1)/scale_value_x;
    else
        best_match_loc2(:,1) = best_match_loc2(:,1)*scale_value_x;
    end
    if (scale_value_y < scale{1}(:,2)) 
        best_match_loc2(:,2) = best_match_loc2(:,2)/scale_value_y;
    else
        best_match_loc2(:,2) = best_match_loc2(:,2)*scale_value_y;
    end
    
    if (((matches == 1) ||(matches == 2)) && ((kk == 2) || (kk == 1)))
        best_match_loc2 = best_match_loc2;
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
             [best_match_loc1(i,2) best_match_loc2(i,2)+rows1], 'Color', colour_list(kk));
    end
end
%hold off;