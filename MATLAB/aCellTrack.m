
clear all;
close all;

[folder, name, ext] = fileparts( mfilename('fullpath'));
cd(folder);
% % https://blogs.mathworks.com/steve/2006/11/17/labeling-labeled-objects/
% cd 'Google Drive? ? ?Shared drives? ? ?Barocas? ? ?Jayhou? ? ?exp1024? ? ?traction?'


strel_disk=8;%8
thresh2 = 1000;
search_dist = 50;

[FileName,FilePath]=uigetfile({'*.*','All File  s (*.*)'},...
    'Select Image File', 'MultiSelect', 'on');
  
if iscell(FileName)
    filenum = size(FileName,2);
else
    filenum = 1;
end

gcf = figure('Position',[1200,500,800,800]);
sub = [0.1 0.54 0.4 0.4];

for fileno = 1:filenum
    
    if iscell(FileName)
        MultiTiff=tiffread([FilePath FileName{fileno}]);
    else
        MultiTiff=tiffread([FilePath FileName]);
    end
    
    % all images
    for frameno=1:size(MultiTiff,2)
        
        temp = MultiTiff(frameno).data;
        subplot1 = subplot(1,2,1);
        imshow(temp, [])
        colormap(subplot1,'gray')
%         freezeColors
        set(subplot1, 'Position', [0 0.3 0.5 0.5]);
        
        image_double=im2double(temp);
        [bw0]=phase_segment(image_double,strel_disk,thresh2);
        [bw_label, cellN]=bwlabel(bw0); % label each object as 1, 2,3,...
        %     imshow(bw_label == 3)
%         center_array = regionprops(bw_label, 'Centroid');
        
        clear stats cellno bw_select cellpos; 
        for i = 1:cellN
            temp = bw_label; temp(:,:) = 0; temp (bw_label==i) = 1;
            bw_select{i} = temp;
            
            stats(i) = regionprops(bw_select{i},'Area','Centroid','MinorAxisLength','MajorAxisLength');
            
            pos = stats(i).Centroid;
            cellpos(i,:) = pos;

            if frameno == 1
                cellno(i) = i;
            else
                
                clear dist;
                for j = 1:cellNp
                    dist(j) = ((pos(1) - cellposp(j,1)).^2+ (pos(2) - cellposp(j,2)).^2).^0.5;
                end
                
                [tempM,IDmin] = min(dist);
                
                if tempM < search_dist
                    cellno(i) = cellnop(IDmin);
                else
                    cellno(i) = max(cellnop)+1;
                end
                
            end
        end
        
        %% remove duplicate and assigne number
        
        for i = 1:cellN
            if i > 1
                dupID = find (cellno(1:i-1)==cellno(i));
                if dupID > 0
                    cellno(i) = max(cellno)+1;
                end
            end
            bw_select{i}(bw_select{i}==1) = cellno(i);
        end
        

        %% update
        cellNp = cellN;
        cellnop = cellno;
        cellposp = cellpos;
        
        %% put all images together
        bw_labeln = bw_select{1};
        for i = 2:cellN
            bw_labeln = bw_labeln + bw_select{i};
        end
        subplot2 = subplot(1,2,2);
        set(subplot2, 'Position', [0.5 0.3 0.5 0.5]);
        
        newmap = [hsv;hsv;hsv;hsv;hsv;hsv;hsv;hsv;hsv;hsv];                    %starting map
        newmap(1,:) = [1 1 1];        %set that position to white
        
        bw_labeln1 = bw_labeln+1;
        imshow(bw_labeln1,newmap);
        
%         imagesc(bw_labeln);
%         colormap(subplot2,newmap);
%         freezeColors
        
        axis off;
        hold on;
        
        
        for i = 1:cellN
            column  = round(cellpos(i,1));
            row = round(cellpos(i,2));
            
            text(column, row, sprintf('%d', cellno(i)), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle');
        end
        hold off
        
        saveas(gcf,'temp.tif')
        im = imread('temp.tif');
        
        if iscell(FileName)
            filename_save = strcat(FilePath,FileName{fileno});
            
        else
            filename_save = strcat(FilePath,FileName);
        end

        if frameno == 1
            imwrite(im,strcat(filename_save,'.tif'))
        else
            imwrite(im,strcat(filename_save,'.tif'),'WriteMode','append')
        end
        %     close all;
        % update saving variable
        
        cellno_all {frameno} = cellno;
        stats_all {frameno} = stats;
        
    end
    
    save(strcat(filename_save,'.mat'),'cellno_all','stats_all');
    
end





