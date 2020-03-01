clear, clc, close all

music_genre = ["Classical Music", "Country", "Pop_R&B"];
for i = 1:length(music_genre)
    convert_wav_to_mat(music_genre(i))
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
        data_matrix_rand = data_matrix(P);
        
        % save the randomized data matrix
        artistName_format = split(artist_music{i}, ".");
        artist_name = artistName_format{1};
        save_path = strcat(root_dir, "/", artist_name, "_data");
        save(save_path, "data_matrix_rand");
    end
end

function [] = down_sample(music_genre)
    root_dir = strcat("Music/", music_genre, "*.mp3");
    files = dir(root_dir);
    artist_music = {files.name};
    for i = 3:length(artist_music)
        audio_path = strcat(root_dir, "/", artist_music{i});
        [y,Fs] = audioread(audio_path);
        size(y)
        size(Fs)
        sample_factor = 5;
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

