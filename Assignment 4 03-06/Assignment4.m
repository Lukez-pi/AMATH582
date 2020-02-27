clear, clc, close all

load('Data/yale_cropped')
mean_row = mean(img_matrix, 2);
num_col = size(img_matrix, 2);
normalized_img_matrix = double(img_matrix) - repmat(mean_row, [1, num_col]);
tic
[u_crop, s_crop, v_crop] = svd(normalized_img_matrix, 'econ');
toc

function [] = read_img_data()
    root_dir_cropped = "Data/CroppedYale";
    files = dir(root_dir_cropped);
    dirFlags = [files.isdir];
    subFolders = files(dirFlags);
    cropped_image_count = 1;
    for k = 3 : length(subFolders) % the first 2 entries of subfolder will always be . and ..
        subdir_name = subFolders(k).name;
        subdir_path = strcat(root_dir_cropped, "/", subdir_name);
        subdir_list = dir(subdir_path);
        img_name = {subdir_list.name};
        for i = 3:length(img_name)
            img_path = strcat(subdir_path, "/", img_name{i});
            I = imread(img_path);
            img_matrix(:, cropped_image_count) = reshape(I, [], 1);
            cropped_image_count = cropped_image_count + 1;
            % imshow(I);
        end
    end
    save('Data/yale_cropped', 'img_matrix')
end