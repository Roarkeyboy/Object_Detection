% This is  the automation that is completely automated. It finds a match
% with an object and the scene, appends it beside the scene and draws lines
% to the matches. (Most of this is commented in GUI_testing so there is no
% overlap)

function matches = full_run(current_scene,handles,hObject,scene_pgm,new_data,max,matches,best,best_homo,best_match_loc1,best_match_loc2,dilated,new_db,scale,text_string,first_flag)

for ii = 1:length(handles.object_list)  % all objects
    guidata(hObject,handles);
    scene = imread(scene_pgm);
    type = char(handles.object_list(ii));
    disp('--------------------------------------');
    printer = ['Searching for ',type];
    disp(printer);
    d = strcat('input_images/objects/',type);
    files = dir(fullfile(d,'*.pgm'));
    for jj =1:numel(files) % all orientations
        file_name = fullfile(d,files(jj).name);
        image_pgm = file_name;
        try
            disp('---- GETTING MATCHES ----');
            [match_loc1, match_loc2, match_results,des1,loc1,loc2] = new_match(scene_pgm,image_pgm,0,new_data,current_scene);
            disp('---- RANSAC MATCHES ----');
            printer = ['Performing RANSAC on ',strcat(type,'/image_',num2str(jj),'.pgm')];
            disp(printer);
            [H, corrPtIdx] = findHomography(match_loc2',match_loc1');
            [match_loc1,match_loc2,num] = ransac_match(scene_pgm,image_pgm,corrPtIdx,match_results,des1,loc1,loc2,0);
            temp = num;
            if temp > max 
                if (temp > 20) % need at least 20 matches 
                    max = temp;
                    best = image_pgm;
                    best_homo = H;
                    best_match_loc1 = match_loc1;
                    best_match_loc2 = match_loc2; 
                end      
            end
        catch
            disp('Image load error');
        end
    end
    if (best == 0)
        printer2 = ['No good match for ',type];
        disp(printer2);
    else 
        matches = matches + 1;
        new_db(matches) = {[best_match_loc1,best_match_loc2]};
        
        text_string{matches} = type;
        handles.listbox1.String = text_string; % append object to objects found

        [tform, ~, ~] = estimateGeometricTransform(best_match_loc2, best_match_loc1, 'affine');
        imgout = warp_it(best_homo,best,scene,tform); 
        [rows, cols, ~] = size(imgout);
        [rows2, cols2, ~] = size(scene);
        if (rows*cols <= rows2*cols2)  
            dilated = dilate_them(imgout,handles,dilated,matches);
        else
            disp('ERROR TRANSFORMING');
        end
    end 
    if (matches == 1 && first_flag)
        image = imread(strcat('input_images/objects/',type,'/',best(end-4),'.jpg'));
        scene = handles.image_file_rgb;
        app = appendimages(scene,image);
        outlined_app = appendimages(dilated,image);
        app2 = image;
        scale(1) = {[1,1]};
        imwrite(app2,strcat('found_objects/',current_scene,'/append_',num2str(matches),'.pgm'),'pgm');
        imagesc(outlined_app); axis(handles.axes1, 'equal','tight','off')
        first_flag = 0;
    elseif (matches > 1)
        try
            im_2 = imread(strcat('input_images/objects/',type,'/',best(end-4),'.jpg'));
            scene = handles.image_file_rgb;
            [app2,scale] = appendimages2(app2,im_2,scene,matches,scale); % appends images downwards
            imwrite(app2,strcat('found_objects/',current_scene,'/append_',num2str(matches),'.pgm'),'pgm');
            app = appendimages(scene,app2);
            outlined_app = appendimages(dilated,app2);
            imagesc(outlined_app); axis(handles.axes1, 'equal','tight','off')
        catch
            continue
        end
    end   
    if (matches > 0)
       draw_new_lines(scene_pgm,outlined_app,app2,new_db,matches,scale,hObject,handles);
    end
    try
        % update handles to be passed back recursively
        handles.not_outlined = app;
        handles.outlined = outlined_app;
        handles.scene_pgm = scene_pgm;
        handles.app2 = app2;
        handles.new_db = new_db;
        handles.matches = matches;
        handles.scale = scale;
        guidata(hObject,handles);
    catch
        continue;
    end    
    best = 0;
    max = 0;
    drawnow();
end