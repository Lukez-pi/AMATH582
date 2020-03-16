clear, clc, close all

% save_test_training_data_1()
% save_test_training_data_2()
% save_test_training_data_3()

% ploting(1, "f")
% ploting(1, "s")
% ploting(2, "f")
% ploting(2, "s")
% ploting(3, "f")
% ploting(3, "s")

fprintf("task 1\n")
find_principal_component(1, "f")
find_principal_component(1, "s")

fprintf("task 2\n")
find_principal_component(2, "f")
find_principal_component(2, "s")

fprintf("task 3\n")
find_principal_component(3, "f")
find_principal_component(3, "s")




% preprocessing step

% music_genre = ["Classical Music", "Country", "Pop_R&B"];
% for i = 1:length(music_genre)
%     down_sample(music_genre(i))
%     convert_wav_to_mat(music_genre(i))
%     
%     % find_principal_component(music_genre(i))
% end
% save_test_training_data_1()
% save_test_training_data_2()
% save_test_training_data_3()


function [] = down_sample(music_genre)
    filter_dir = strcat("Music/", music_genre, "/*.mp3");
    files = dir(filter_dir);
    artist_music = {files.name};
    for i = 1:length(artist_music)
        root_dir = strcat("Music/", music_genre);
        audio_path = strcat(root_dir, "/", artist_music{i});
        [y,Fs] = audioread(audio_path);
        size(y)
        size(Fs)
        sample_factor = 2;
        Fs = Fs / sample_factor; % sample a point out of every 5 sample points
        y = y(1:sample_factor:end, 1);
        t = (1:length(y)) / Fs;
        
        % playerObj = audioplayer(y, Fs);
        % start_time = playerObj.SampleRate * 4;
        % stop_time = playerObj.SampleRate * 20;
        % playblocking(playerObj, [start_time, stop_time]);
        artistName_format = split(artist_music{i}, ".");
        artist_name = artistName_format{1};
        output_audio_path = strcat(root_dir, "/", artist_name, "_processed.wav");
        audiowrite(output_audio_path, y, Fs);
    end
end

function [] = convert_wav_to_mat(music_genre)
    file_format = "/*.wav";
    filter_dir = strcat("Music/", music_genre, file_format);
    files = dir(filter_dir);
    artist_music = {files.name};
    for i = 1:length(artist_music)
        root_dir = strcat("Music/", music_genre);
        audio_path = strcat(root_dir, "/", artist_music{i});
        [y,Fs] = audioread(audio_path);
        time_interval = 5;
        feature_num = time_interval * Fs;
        length_y = length(y);
        sample_num = floor(length_y / feature_num);
        truncate_num = mod(length_y, feature_num);
        data_matrix = reshape(y(1:length_y - truncate_num), feature_num, sample_num);
                
        % randomly shuffle the vectors
        cols = size(data_matrix, 2);
        P = randperm(cols);
        data_matrix_rand = data_matrix(:, P);
        
        playerObj = audioplayer(data_matrix_rand(:, 147), Fs);
        playblocking(playerObj);
        
        % save the randomized data matrix
        artistName_format = split(artist_music{i}, ".");
        artist_name = artistName_format{1};
        save_path = strcat(root_dir, "/", artist_name, "_data");
        save(save_path, "data_matrix_rand");
    end
end

function [] = save_test_training_data_1()
    folder = ["Classical Music", "Country", "Pop_R&B"];
    file_format = "/*.mat";
    data = [];
    data_fourier = [];
    training_set = [];
    training_set_fourier = [];
    training_set_label = [];
    test_set_data = [];
    test_set_fourier = [];
    test_set_label = [];
    clip_nums = [0];
    training_nums = [];
    
    for i = 1:length(folder)
        root_dir = strcat("Music/", folder(i), file_format);
        files = dir(root_dir);
        artist_music = {files.name};
        file_path = strcat("Music/", folder(i), "/", artist_music{1});
        load(file_path);
        fft_data = [];
        spectrogram_data = [];
        for clip = 1:size(data_matrix_rand, 2)
            spectrogram_data = [spectrogram_data, max(abs(spectrogram(data_matrix_rand(:, clip), 128, 120, 128, 500)))'];
            fft_data = [fft_data, abs(fft(data_matrix_rand(:, clip)))];
        end
        data = [data, spectrogram_data];
        data_fourier = [data_fourier, fft_data];
        
        clip_num = size(data_matrix_rand, 2);
        clip_nums = [clip_nums, clip_num];
        training_num = floor(0.8 * clip_num);
        training_nums = [training_nums, training_num];
    end
    
    mean_row = mean(data, 2);
    data = data - mean_row;
    tic
    [~, s, v] = svd(data, 'econ');
    toc
    
    mean_row_fourier = mean(data_fourier, 2);
    data_fourier = data_fourier - mean_row_fourier;
    tic
    [~, s2, v2] = svd(data_fourier, 'econ');
    toc
    
    sig = diag(s);
    sig_fourier = diag(s2);
    
    figure()
    plot(linspace(1, length(sig), length(sig)), sig, 'ko')
    xlabel("Mode")
    ylabel("Sigma")
    save("Data/Q2/sigma_1_s.mat", "sig")
    
    figure()
    plot(linspace(1, length(sig), length(sig)), sig_fourier, 'ko')
    xlabel("Mode")
    ylabel("Sigma")
    save("Data/Q2/sigma_1_f.mat", "sig_fourier")
    
    feature_num = 20;
    color = ['r', 'g', 'b'];
    pca = [];
    for i = 1:length(clip_nums)-1
        training_set_start = sum(clip_nums(1:i)) + 1;
        training_set_end = sum(clip_nums(1:i)) + training_nums(i);
        
        training_set = [training_set; v(training_set_start:training_set_end, 1:feature_num)];
        training_set_fourier = [training_set_fourier; v2(training_set_start:training_set_end, 1:feature_num)];
        training_set_label = [training_set_label; i*ones(training_nums(i), 1)];
        
        pca = [pca; v(training_set_start:training_set_end, 1:3), v2(training_set_start:training_set_end, 1:3)];
        
        test_set_start = sum(clip_nums(1:i)) + training_nums(i) + 1;
        test_set_end = sum(clip_nums(1:i+1));
        test_set_length = test_set_end - test_set_start + 1;
        
        test_set_data = [test_set_data; v(test_set_start:test_set_end, 1:feature_num)];
        test_set_fourier = [test_set_fourier; v2(test_set_start:test_set_end, 1:feature_num)];
        test_set_label = [test_set_label; i*ones(test_set_length, 1)];
    end
    
    save_dir_train_f = "Data/Q2/Part_1_training_data_f.mat";
    save_dir_test_f = "Data/Q2/Part_1_test_data_f.mat";
    save_dir_v_f = "Data/Q2/Part_1_v_f.mat";
    save(save_dir_train_f, "training_set_fourier");
    save(save_dir_test_f, "test_set_fourier");
    save(save_dir_v_f, "v2");
    
    save_dir_train_s = "Data/Q2/Part_1_training_data_s.mat";
    save_dir_test_s = "Data/Q2/Part_1_test_data_s.mat";
    save_dir_v_s = "Data/Q2/Part_1_v_s.mat";
    save(save_dir_train_s, "training_set");
    save(save_dir_test_s, "test_set_data");
    save(save_dir_v_s, "v");
    
    save_dir_dim = "Data/Q2/Part_1_dim.mat";
    save(save_dir_dim, "clip_nums", "training_nums");
    
    save_dir_train_label = "Data/Q2/Part_1_training_label.mat";
    save_dir_test_label = "Data/Q2/Part_1_test_label.mat";
    save(save_dir_train_label, "training_set_label");
    save(save_dir_test_label, "test_set_label");    
end

function [] = save_test_training_data_2()
    genre = "Country";
    file_format = "/*.mat";
    data = [];
    data_fourier = [];
    training_set = [];
    training_set_fourier = [];
    training_set_label = [];
    test_set_data = [];
    test_set_fourier = [];
    test_set_label = [];
    clip_nums = [0];
    training_nums = [];
    
    filter_dir = strcat("Music/", genre, file_format);
    files = dir(filter_dir);
    artist_music = {files.name};
    
    for i = 1:3
        file_path = strcat("Music/", genre, "/", artist_music{i});
        load(file_path);
        fft_data = [];
        spectrogram_data = [];
        for clip = 1:size(data_matrix_rand, 2)
            spectrogram_data = [spectrogram_data, max(abs(spectrogram(data_matrix_rand(:, clip), 128, 120, 128, 500)))'];
            fft_data = [fft_data, abs(fft(data_matrix_rand(:, clip)))];
        end
        data = [data, spectrogram_data];
        data_fourier = [data_fourier, fft_data];
        
        clip_num = size(data_matrix_rand, 2);
        clip_nums = [clip_nums, clip_num];
        training_num = floor(0.8 * clip_num);
        training_nums = [training_nums, training_num];
    end
    
    mean_row = mean(data, 2);
    data = data - mean_row;
    tic
    [~, s, v] = svd(data, 'econ');
    toc
    
    mean_row_fourier = mean(data_fourier, 2);
    data_fourier = data_fourier - mean_row_fourier;
    tic
    [~, s2, v2] = svd(data_fourier, 'econ');
    toc
    
    sig = diag(s);
    sig_fourier = diag(s2);
    
    figure()
    plot(linspace(1, length(sig), length(sig)), sig, 'ko')
    xlabel("Mode")
    ylabel("Sigma")
    save("Data/Q2/sigma_2_s.mat", "sig")
    
    figure()
    plot(linspace(1, length(sig), length(sig)), sig_fourier, 'ko')
    xlabel("Mode")
    ylabel("Sigma")
    save("Data/Q2/sigma_2_f.mat", "sig_fourier")
    
    feature_num = 20;
    pca = [];
    for i = 1:length(clip_nums)-1
        training_set_start = sum(clip_nums(1:i)) + 1;
        training_set_end = sum(clip_nums(1:i)) + training_nums(i);
        
        training_set = [training_set; v(training_set_start:training_set_end, 1:feature_num)];
        training_set_fourier = [training_set_fourier; v2(training_set_start:training_set_end, 1:feature_num)];
        training_set_label = [training_set_label; i*ones(training_nums(i), 1)];
        
        pca = [pca; v(training_set_start:training_set_end, 1:3), v2(training_set_start:training_set_end, 1:3)];
        
        test_set_start = sum(clip_nums(1:i)) + training_nums(i) + 1;
        test_set_end = sum(clip_nums(1:i+1));
        test_set_length = test_set_end - test_set_start + 1;
        
        test_set_data = [test_set_data; v(test_set_start:test_set_end, 1:feature_num)];
        test_set_fourier = [test_set_fourier; v2(test_set_start:test_set_end, 1:feature_num)];
        test_set_label = [test_set_label; i*ones(test_set_length, 1)];
    end
    
    save_dir_train_f = "Data/Q2/Part_2_training_data_f.mat";
    save_dir_test_f = "Data/Q2/Part_2_test_data_f.mat";
    save_dir_v_f = "Data/Q2/Part_2_v_f.mat";
    save(save_dir_train_f, "training_set_fourier");
    save(save_dir_test_f, "test_set_fourier");
    save(save_dir_v_f, "v2");
    
    save_dir_train_s = "Data/Q2/Part_2_training_data_s.mat";
    save_dir_test_s = "Data/Q2/Part_2_test_data_s.mat";
    save_dir_v_s = "Data/Q2/Part_2_v_s.mat";
    save(save_dir_train_s, "training_set");
    save(save_dir_test_s, "test_set_data");
    save(save_dir_v_s, "v");
    
    save_dir_dim = "Data/Q2/Part_2_dim.mat";
    save(save_dir_dim, "clip_nums", "training_nums");
    
    save_dir_train_label = "Data/Q2/Part_2_training_label.mat";
    save_dir_test_label = "Data/Q2/Part_2_test_label.mat";
    save(save_dir_train_label, "training_set_label");
    save(save_dir_test_label, "test_set_label");    
end

function [] = save_test_training_data_3()
    folder = ["Classical Music", "Country", "Pop_R&B"];
    file_format = "/*.mat";
    data = [];
    data_fourier = [];
    training_set = [];
    training_set_fourier = [];
    training_set_label = [];
    test_set_data = [];
    test_set_fourier = [];
    test_set_label = [];
    clip_nums = [0];
    training_nums = [];
    
    for i = 1:length(folder)
        filter_dir = strcat("Music/", folder(i), file_format); % pick the genre
        files = dir(filter_dir);
        artist_music = {files.name};
        
        clip_num = 0;
        for j = 1:3
            file_path = strcat("Music/", folder(i), "/", artist_music{j});
            load(file_path);
            fft_data = [];
            spectrogram_data = [];
            num_clip_singer = 300;
            for clip = 1:num_clip_singer
                spectrogram_data = [spectrogram_data, max(abs(spectrogram(data_matrix_rand(:, clip), 128, 120, 128, 500)))'];
                fft_data = [fft_data, abs(fft(data_matrix_rand(:, clip)))];
            end
            data = [data, spectrogram_data];
            data_fourier = [data_fourier, fft_data];

            clip_num = clip_num + num_clip_singer;
        end
        clip_nums = [clip_nums, clip_num];
        training_num = floor(0.8 * clip_num);
        training_nums = [training_nums, training_num];
    end
    mean_row = mean(data, 2);
    data = data - mean_row;
    tic
    [~, s, v] = svd(data, 'econ');
    toc
    
    mean_row_fourier = mean(data_fourier, 2);
    data_fourier = data_fourier - mean_row_fourier;
    tic
    [~, s2, v2] = svd(data_fourier, 'econ');
    toc
    
    sig = diag(s);
    sig_fourier = diag(s2);
    
    figure()
    plot(linspace(1, length(sig), length(sig)), sig, 'ko')
    xlabel("Mode")
    ylabel("Sigma")
    save("Data/Q2/sigma_3_s.mat", "sig")
    
    figure()
    plot(linspace(1, length(sig), length(sig)), sig_fourier, 'ko')
    xlabel("Mode")
    ylabel("Sigma")
    save("Data/Q2/sigma_3_f.mat", "sig_fourier")
    
    feature_num = 20;
    color = ['r', 'g', 'b'];
    pca = [];
    for i = 1:length(clip_nums)-1
        training_set_start = sum(clip_nums(1:i)) + 1;
        training_set_end = sum(clip_nums(1:i)) + training_nums(i);
        
        training_set = [training_set; v(training_set_start:training_set_end, 1:feature_num)];
        training_set_fourier = [training_set_fourier; v2(training_set_start:training_set_end, 1:feature_num)];
        training_set_label = [training_set_label; i*ones(training_nums(i), 1)];
        
        pca = [pca; v(training_set_start:training_set_end, 1:3), v2(training_set_start:training_set_end, 1:3)];
        
        test_set_start = sum(clip_nums(1:i)) + training_nums(i) + 1;
        test_set_end = sum(clip_nums(1:i+1));
        test_set_length = test_set_end - test_set_start + 1;
        
        test_set_data = [test_set_data; v(test_set_start:test_set_end, 1:feature_num)];
        test_set_fourier = [test_set_fourier; v2(test_set_start:test_set_end, 1:feature_num)];
        test_set_label = [test_set_label; i*ones(test_set_length, 1)];
    end
    
    save_dir_train_f = "Data/Q2/Part_3_training_data_f.mat";
    save_dir_test_f = "Data/Q2/Part_3_test_data_f.mat";
    save_dir_v_f = "Data/Q2/Part_3_v_f.mat";
    save(save_dir_train_f, "training_set_fourier");
    save(save_dir_test_f, "test_set_fourier");
    save(save_dir_v_f, "v2");
    
    save_dir_train_s = "Data/Q2/Part_3_training_data_s.mat";
    save_dir_test_s = "Data/Q2/Part_3_test_data_s.mat";
    save_dir_v_s = "Data/Q2/Part_3_v_s.mat";
    save(save_dir_train_s, "training_set");
    save(save_dir_test_s, "test_set_data");
    save(save_dir_v_s, "v");
    
    save_dir_dim = "Data/Q2/Part_3_dim.mat";
    save(save_dir_dim, "clip_nums", "training_nums");
    
    save_dir_train_label = "Data/Q2/Part_3_training_label.mat";
    save_dir_test_label = "Data/Q2/Part_3_test_label.mat";
    save(save_dir_train_label, "training_set_label");
    save(save_dir_test_label, "test_set_label");    
end

function [] = ploting(part_num, datatype)
    s_struct = load(strcat("Data/Q2/sigma_", num2str(part_num), "_", datatype, ".mat"));
    struct_name = fieldnames(s_struct);
    struct_name = struct_name{1};
    sig = s_struct.(struct_name);
    figure()
    plot(linspace(1, length(sig), length(sig)), sig, 'ko')
    xlabel("Mode")
    ylabel("Sigma")
    print_figure(strcat("Figures/Q2/", num2str(part_num), "_sigma_", datatype), 8.5, 8, 6)
    
    semilogy(linspace(1, length(sig), length(sig)), sig, 'ko')
    xlabel("Mode")
    ylabel("log10(Sigma)")
    print_figure(strcat("Figures/Q2/", num2str(part_num), "_log_sigma_", datatype), 8.5, 8, 6)
    
    load(strcat("Data/Q2/Part_", num2str(part_num), "_dim.mat"))
    v_struct = load(strcat("Data/Q2/Part_", num2str(part_num), "_v_", datatype, ".mat"));
    struct_name = fieldnames(v_struct);
    struct_name = struct_name{1};
    v = v_struct.(struct_name);
    color = ['r', 'b', 'y'];
    figure()
    for i = 1:3
        data = v(sum(clip_nums(1:i))+1:sum(clip_nums(1:i+1)), 1:3);
        scatter3(data(:, 1), data(:, 2), data(:, 3), 12, color(i), 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.25)
        hold on
    end
    xlabel("PCA1")
    ylabel("PCA2")
    zlabel("PCA3")
    print_figure(strcat("Figures/Q2/", num2str(part_num), "_3D_projection_", datatype), 8.5, 8, 6)
end

function [] = find_principal_component(part_num, datatype)
    training_struct = load(strcat("Data/Q2/Part_", num2str(part_num), "_training_data_", datatype, ".mat"));
    struct_name = fieldnames(training_struct);
    struct_name = struct_name{1};
    training_set = training_struct.(struct_name);
    load(strcat("Data/Q2/Part_", num2str(part_num), "_training_label.mat"));
    
    test_struct = load(strcat("Data/Q2/Part_", num2str(part_num), "_test_data_", datatype, ".mat"));
    struct_name = fieldnames(test_struct);
    struct_name = struct_name{1};
    test_set = test_struct.(struct_name);
    load(strcat("Data/Q2/Part_", num2str(part_num), "_test_label.mat"));
    
    for feature_num = 3:3
%         test_s = test_set_data(:, 1:feature_num);
%         train_s = training_set(:, 1:feature_num);
        
        test_s = test_set(:, 1:feature_num);
        train_s = training_set(:, 1:feature_num);
        
        t = templateSVM('Standardize',true);        
        mdl = fitcecoc(train_s, training_set_label, 'Learners', t);%, 'ClassNames', {'1', '2', '3'});
        label = predict(mdl, test_s);
        L = resubLoss(mdl);
        fprintf("This is the training set accuracy %d\n", (1 - L) * 100);
        err_rate = nnz(label - test_set_label) / length(label); % error rate
        fprintf("This is the test set accuracy %d\n", (1- err_rate) * 100);
    end
end

function [] = print_figure(file_name, font_size, fig_width, fig_height)
    fig = gcf;
    set(gca, 'Fontsize', font_size)
    fig.PaperUnits = "centimeters";
    fig.PaperPosition = [0 0 fig_width fig_height];
    fig.PaperSize = [fig_width fig_height];
    print(file_name,'-dpdf')
end