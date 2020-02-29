clear, clc, close all

% read_img_data("Data/CroppedYale", "")
% load('Data/u_cropped')
% load('Data/v_cropped')
% load('Data/s_cropped')
% analysis_and_plot(u_crop, s_crop, v_crop, 192, 168)

load('Data/u_uncropped')
load('Data/v_uncropped')
load('Data/s_uncropped')
analysis_and_plot(u_uncropped, s_uncropped, v_uncropped, 243, 320)


function [] = analysis_and_plot(u, s, v, img_len, img_wid)
    sig = diag(s);
    figure()
    plot(linspace(1, length(sig), length(sig)), sig, 'ko')
    xlabel("Mode")
    ylabel("Sigma")
    % print_figure("Figures/Q1/sigma", 8.5, 8, 6)
    
    figure()
    semilogy(linspace(1, length(sig), length(sig)), sig, 'ko')
    xlabel("Mode")
    ylabel("log10(Sigma)")
    % print_figure("Figures/Q1/log_sigma", 8.5, 8, 6)
    
    sig_sum = 0;
    idx = 0;
    for i = 1:length(sig)
        sig_sum = sig_sum + sig(i);
        energy = sig_sum / sum(sig);
        energy_arr(i) = energy;
        if energy < 0.50
            idx = idx + 1;
        end
    end
    
    figure()
    plot(linspace(1, length(sig), length(sig)), energy_arr, 'ko')
    xlabel("Mode")
    ylabel("Energy")
    idx
    
    load('Data/yale_uncropped')
    % plot singular value spectrum
    for i = 1:size(u, 2)
        imshow(reshape(u(:, i), img_len, img_wid), 'DisplayRange', [])
    end
    
    for i = 1:size(u, 2)
        approx = u(:, 1:i) * s(1:i, 1:i) * v(:, 1:i)';
        for j = 1:100
            img_data = approx(:, j);
            figure(1)
            imshow(reshape(img_data, img_len, img_wid), 'DisplayRange', [])
            figure(2)
            imshow(reshape(img_matrix(:, j), img_len, img_wid), 'DisplayRange', [])
        end            
    end
%     for i = 1:size(approx, 2)
%         img_data = approx(:, i);
%         max_val = max(img_data(:));
%         min_val = min(img_data(:));
%         img_data = (img_data - min_val) / (max_val - min_val) * 255;
%         imshow(reshape(img_data, img_len, img_wid), 'DisplayRange', [0, 255])
%     end
end

function [] = read_img_data(root_dir, save_file_name)
    files = dir(root_dir);
    dirFlags = [files.isdir];
    subFolders = files(dirFlags);
    image_count = 1;
    if length(subFolders) >= 3
        for k = 3 : length(subFolders) % the first 2 entries of subfolder will always be . and ..
            subdir_name = subFolders(k).name;
            subdir_path = strcat(root_dir, "/", subdir_name);
            subdir_list = dir(subdir_path);
            img_name = {subdir_list.name};
            for i = 3:length(img_name)
                img_path = strcat(subdir_path, "/", img_name{i});
                I = imread(img_path);
                img_matrix(:, image_count) = reshape(I, [], 1);
                image_count = image_count + 1;
                imshow(I);
            end
        end
    else
        img_name = {files.name};
        for i = 3:length(img_name)
            img_path = strcat(root_dir, "/", img_name{i});
            I = imread(img_path);
            img_matrix(:, image_count) = reshape(I, [], 1);
            image_count = image_count + 1;
            imshow(I);
        end
    end
    if length(save_file_name) > 1
        save_path = strcat("Data/", save_file_name);
        save(save_path, 'img_matrix')
    end
end

function [u, s, v] = pca(img_matrix)
    mean_row = mean(img_matrix, 2);
    num_col = size(img_matrix, 2);
    normalized_img_matrix = double(img_matrix) - repmat(mean_row, [1, num_col]);
    tic
    [u, s, v] = svd(normalized_img_matrix, 'econ');
    toc
end

function [] = save_data()
    read_img_data("Data/yalefaces", "yale_uncropped")
    load('Data/yale_uncropped')
    [u_uncropped, s_uncropped, v_uncropped] = pca(img_matrix);
    save('Data/u_uncropped', 'u_uncropped')
    save('Data/s_uncropped', 's_uncropped')
    save('Data/v_uncropped', 'v_uncropped')
end

function [] = print_figure(file_name, font_size, fig_width, fig_height)
    fig = gcf;
    set(gca, 'Fontsize', font_size)
    fig.PaperUnits = "centimeters";
    fig.PaperPosition = [0 0 fig_width fig_height];
    fig.PaperSize = [fig_width fig_height];
    print(file_name,'-dpdf')
end
