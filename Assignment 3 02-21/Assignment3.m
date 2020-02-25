clear, clc, close all

    
    \ENDFOR
   
        

initial_pt_ps1 = [350 250; 300 325; 350 300];
initial_pt_ps2 = [340 350; 320 360; 380 280];
initial_pt_ps3 = [350 320; 260 330; 405 245];
initial_pt_ps4 = [400 265; 330 270; 390 210];

%%
% analyze_data(1, initial_pt_ps1);
% [frame_num] = preprocess_data(1, [1, 11, 1]);
% visualize_first_frame(1)
initial_pt_ps1 = [350 250; 300 225; 360 295];
can_position_1 = track_can(1, initial_pt_ps1, false);
[approx, u, idx] = find_principal_component(1, can_position_1, 2);
figure()
scatter(approx(1, :), approx(2, :))
max_lim = max(approx(1, :));
xlabel("Vertical position (pixel)")
ylabel("Horizontal position (pixel)")
axis([-max_lim max_lim -max_lim max_lim])
print_figure("Figures/Q1/1_projection", 8.5, 8, 6)

%%
% analyze_data(2, initial_pt_ps2);
% [frame_num] = preprocess_data(2, [33, 17, 37]);
% visualize_first_frame(2)
initial_pt_ps2 = [350 275; 380 190; 345 280];
can_position_2 = track_can(2, initial_pt_ps2, false);
[approx, u, idx] = find_principal_component(2, can_position_2, 2);
figure()
scatter(approx(1, :), approx(2, :)) 
max_lim = max(approx(1, :));
xlabel("Vertical position (pixel)")
ylabel("Horizontal position (pixel)")
axis([-max_lim max_lim -max_lim max_lim])
print_figure("Figures/Q2/2_projection", 8.5, 8, 6)

%%
% analyze_data(3, initial_pt_ps3);
% [frame_num] = preprocess_data(3, [8, 38, 1]);
% visualize_first_frame(3)
initial_pt_ps3 = [350 325; 330 300; 390 230];
can_position_3 = track_can(3, initial_pt_ps3, false);
[approx, u, idx] = find_principal_component(3, can_position_3, 2);
figure()
plot(approx(1, :), approx(2, :))
xlabel("Vertical position (pixel)")
ylabel("Horizontal position (pixel)")
max_lim = max(approx(1, :));
axis([-max_lim max_lim -max_lim max_lim])
print_figure("Figures/Q3/3_projection", 8.5, 8, 6)

%%
% analyze_data(4, initial_pt_ps4);
% [frame_num] = preprocess_data(4, [33, 39, 32]);
% visualize_first_frame(4)
can_frame_4 = [225 375 300 450; 75 300 200 400; 175 300 325 550];
can_position_4 = track_can_pixel(4, can_frame_4, false);
[approx, u, idx] = find_principal_component(4, can_position_4, 3);
figure()
scatter(approx(1, :), approx(2, :))
xlabel("Vertical position (pixel)")
ylabel("Horizontal position (pixel)")
max_lim = max(approx(1, :));
axis([-max_lim max_lim -max_lim max_lim])
print_figure("Figures/Q4/4_projection", 8.5, 8, 6)

function [] = print_figure(file_name, font_size, fig_width, fig_height)
    fig = gcf;
    set(gca, 'Fontsize', font_size)
    fig.PaperUnits = "centimeters";
    fig.PaperPosition = [0 0 fig_width fig_height];
    fig.PaperSize = [fig_width fig_height];
    print(file_name,'-dpdf')
end

function [frame_num] = preprocess_data(ps, start_frame_num)
    [cam_data1, frame_num1] = truncate_beginning(1, ps, start_frame_num(1));
    [cam_data2, frame_num2] = truncate_beginning(2, ps, start_frame_num(2));
    [cam_data3, frame_num3] = truncate_beginning(3, ps, start_frame_num(3));
    
    frame_num = min([frame_num1, frame_num2, frame_num3]);
    cam_data1 = cam_data1(:, :, :, 1:frame_num);
    cam_data2 = cam_data2(:, :, :, 1:frame_num);
    cam_data3 = cam_data3(:, :, :, 1:frame_num);
    
    % visualize(cam_data1, cam_data2, cam_data3, frame_num);
    
    save_video = true;
    save_data(cam_data1, 1, save_video);
    save_data(cam_data2, 2, save_video);
    save_data(cam_data3, 3, save_video);
    
    function [cam_data, frame_num] = truncate_beginning(cam_num, ps, start_frame_num)
        file_name = strcat("Data/raw data/cam", num2str(cam_num), "_", num2str(ps), ".mat");
        cam_data = importdata(file_name);
        cam_data = cam_data(:, :, :, start_frame_num:end);
        frame_num = size(cam_data, 4);
    end

    function [] = save_data(cam_data, cam_num, save_video)
        outfile_name = strcat("Data/synchronized data/cam", num2str(cam_num), "_", num2str(ps));
        save(outfile_name, 'cam_data')
        
        if save_video == true            
            output_video = VideoWriter(strcat("Data/videos/cam", num2str(cam_num), "_", num2str(ps), ".avi"));
            open(output_video);

            for ii = 1:size(cam_data, 4)
                writeVideo(output_video, cam_data(:, :, :, ii));
            end
            close(output_video);    
        end
    end

    function [] = visualize(cam_data1, cam_data2, cam_data3, frame_num)
        for f = 1:frame_num
            figure(1)
            imshow(cam_data1(:, :, :, f))
            hold on 
            figure(2)
            imshow(cam_data2(:, :, :, f))
            hold on
            figure(3)
            imshow(cam_data3(:, :, :, f))
            pause(0.1)
            hold on 
        end
    end    
end

function [] = visualize_first_frame(ps)
    for cam_num = 1:3
        file_name = strcat("Data/synchronized data/cam", num2str(cam_num), "_", num2str(ps), ".mat");
        cam_data = importdata(file_name);
        imshow(cam_data(:, :, :, 1));
        h = gca;
        h.Visible = "On";
    end    
end    

function [can_position] = track_can(ps, initial_pt, visualization)
    for cam_num = 3:3
        file_name = strcat("Data/synchronized data/cam", num2str(cam_num), "_", num2str(ps), ".mat");
        cam_data = importdata(file_name);
        frame_num = size(cam_data, 4);
        point_tracker = vision.PointTracker("NumPyramidLevels", 15, "BlockSize", [61 61]);
        first_frame = cam_data(:, :, :, 1);
        initialize(point_tracker, initial_pt(cam_num, :), first_frame);
        for frame = 1:frame_num
            video_frame = cam_data(:, :, :, frame);             
            [points, ~] = point_tracker(video_frame);
            can_position(2 * cam_num - 1 : 2 * cam_num, frame) = points';
            
            % plotting for data visualization 
            if visualization == true
                figure(1)
                imshow(video_frame)
                hold on 
                plot(points(1), points(2), 's', 'MarkerSize', 5, 'MarkerFaceColor', [0 0 0])
                h = gca;
                h.Visible = "On";
                pause(0.1)
            end
        end
    end
end

function [can_position] = track_can_pixel(ps, can_frame, visualization)
    for cam_num = 1:3
        file_name = strcat("Data/synchronized data/cam", num2str(cam_num), "_", num2str(ps), ".mat");
        cam_data = importdata(file_name);
        frame_num = size(cam_data, 4);
        for frame = 1:frame_num
            NMax = 100;
            I = rgb2gray(cam_data(:, :, :, frame));    
            I_can = I(can_frame(cam_num, 1):can_frame(cam_num, 2), can_frame(cam_num, 3):can_frame(cam_num, 4));
            [Ivec, Ind] = sort(I_can(:), 1, 'descend');
            [ind_row, ind_col] = ind2sub(size(I_can), Ind(1:NMax));
            mean_row = mean(ind_row);
            mean_col = mean(ind_col);
            can_position(2 * cam_num - 1 : 2 * cam_num, frame) = [mean_col + can_frame(cam_num, 3); mean_row + can_frame(cam_num, 1)];
            % [max_col, idx_row] = max(I(can_frame(cam_num, 1):can_frame(cam_num, 2), can_frame(cam_num, 3):can_frame(cam_num, 4)));
            % [~, idx_col] = max(max_col);
            % can_position(2 * cam_num - 1 : 2 * cam_num, frame) = [idx_col + can_frame(cam_num, 3); idx_row(idx_col) + can_frame(cam_num, 1)];
            if visualization == true
                figure(1)
                imshow(I)
                hold on 
                plot(mean_col + can_frame(cam_num, 3), mean_row + can_frame(cam_num, 1), 's', 'MarkerSize', 5, 'MarkerFaceColor', [0 0 0])
                h = gca;
                h.Visible = "On";
                pause(0.1)
            end
        end
    end
end

function [approx, u, idx] = find_principal_component(ps, can_position, dim)    
    mean_feature = mean(can_position, 2);
    normalized_can_position = can_position - mean_feature;
    % solving for principal component using eigenvalue-eigenvector
    % decomposition
%     Sigma = 1/226 * normalized_can_position * normalized_can_position';
%     [u, s, v] = svd(Sigma);
%     Ureduce = u(:, 1:2);
%     z = Ureduce' * normalized_can_position;
    [u, s, v] = svd(normalized_can_position);
    [u2, s2, v2] = svd(normalized_can_position');
    sig = diag(s);
    sig_sum = 0;
    idx = 0;
    for i = 1:length(sig)
        sig_sum = sig_sum + sig(i);
        idx = idx + 1;
        energy = sig_sum / sum(sig);
        if energy > 0.99
            break
        end
    end
    approx = u(:, 1:dim)' * normalized_can_position;
    approx2 = normalized_can_position' * v2(:, 1:dim);
    
    folder_name = strcat("Figures/Q", num2str(ps), "/");
    figure()
    plot(linspace(1, 6, 6), sig, 'ko', 'Linewidth', 1.5)
    xlabel("Mode")
    ylabel("Sigma")
    file_name = strcat(folder_name, num2str(ps), "_sigma");
    print_figure(file_name, 8.5, 5, 4.5)
        
    figure()
    semilogy(linspace(1, 6, 6), sig, 'ko', 'Linewidth', 1.5)
    xlabel("Mode")
    ylabel("log10(Sigma)")
    file_name = strcat(folder_name, num2str(ps), "_log_sigma");
    print_figure(file_name, 8.5, 5, 4.5)
    
    figure()
    linestyle = ['k', 'r:', 'b--'];
    for d = 1:dim
        plot(linspace(1, size(u,1), size(u,1)), u(:, d), linestyle(d), 'Linewidth', 2)
        hold on
    end
    legend('mode 1', 'mode 2', 'mode 3', 'Location', 'NorthWest')
    text(8, 0.35, '(c)', 'Fontsize', 13)
    xlabel("Dimension")
    ylabel("Magnitude")
    file_name = strcat(folder_name, num2str(ps), "_modes");
    print_figure(file_name, 8.5, 5, 4.5)
    
    figure()
    linestyle = ['k', 'r:', 'b--'];
    for d = 1:dim
        plot(linspace(1, length(v), length(v)), v(:, d), linestyle(d), 'Linewidth', 2)
        hold on
    end
    legend('mode 1', 'mode 2', 'mode 3', 'Location', 'NorthWest')
    text(8, 0.35, '(c)', 'Fontsize', 13)
    xlabel("Frame number")
    ylabel("Magnitude")
    file_name = strcat(folder_name, num2str(ps), "_time_evo");
    print_figure(file_name, 8.5, 8, 6)
end

% the function used to learn about and visualize the data
function [] = analyze_data(ps, initial_pt)  
    for cam_num = 1:3
        file_name = strcat("Data/raw data/cam", num2str(cam_num), "_", num2str(ps), ".mat");
        cam_data = importdata(file_name);

        point_tracker = vision.PointTracker("NumPyramidLevels", 15, "BlockSize", [61 61]);
        first_frame = cam_data(:, :, :, 1);
        initialize(point_tracker, initial_pt(cam_num, :), first_frame);
        point_arr = zeros(50, 2);
        for i = 1:50
            video_frame = cam_data(:, :, :, i); 
            [points, ~] = point_tracker(video_frame);
            point_arr(i, :) = points;
        end
        figure()
        [max_y_pos, start_frame_num] = max(point_arr(:, 2));
        plot(point_arr)
    end
end
