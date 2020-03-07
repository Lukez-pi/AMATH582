clear, clc, close all

% save_test_training_data_1()
% find_principal_component()
% save_test_training_data_2()
save_test_training_data_3()



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
    save("Data/Q2/sigma_1_f.mat", "sig")
    
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
    save("Data/Q2/sigma_2_f.mat", "sig")
    
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
    save("Data/Q2/sigma_3_f.mat", "sig")
    
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


function [] = find_principal_component(music_genre)
    load("Data/Q2/Part_1_training_data_f.mat");
    load("Data/Q2/Part_1_training_label.mat");
    load("Data/Q2/Part_1_test_data_f.mat");
    load("Data/Q2/Part_1_test_label.mat");
    
    for feature_num = 1:10
%         test_s = test_set_data(:, 1:feature_num);
%         train_s = training_set(:, 1:feature_num);
        
        test_s = test_set_fourier(:, 1:feature_num);
        train_s = training_set_fourier(:, 1:feature_num);
        
        t = templateSVM('Standardize',true);        
        mdl = fitcecoc(train_s, training_set_label, 'Learners', t);%, 'ClassNames', {'1', '2', '3'});
        label = predict(mdl, test_s)
        resubLoss(mdl)
        nnz(label - test_set_label) / length(label) % error rate
    end
end

function [] = linear_discriminant_analysis()
end