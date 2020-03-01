clear, clc, close all

music_genre = ["Classical Music", "Country", "Pop_R&B"];
for j = 1:length(music_genre)
    root_dir = strcat("Music/", music_genre(j));
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

