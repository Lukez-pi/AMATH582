clear, clc, close all

figure(2)
tr_rec = 14;
S = audioread('music2.wav'); Fs = length(S)/tr_rec;
t = (1:length(S))/Fs; 
L = length(S)/Fs; n = length(S);
k = (2*pi/L)*[0:n/2-1 -n/2:-1]; ks = fftshift(k);
plot((1:length(S))/Fs, S);
xlabel('Time [sec]'); ylabel('Amplitude');
title('Mary had a little lamb (recorder)');
% p8 = audioplayer(S, Fs); playblocking(p8);

tr_piano = 16;
S = audioread('music1.wav'); Fs = length(S)/tr_piano;
t = (1:length(S))/Fs; 
L = length(S)/Fs; n = length(S);
k = (2*pi/L)*[0:n/2-1 -n/2:-1]; ks = fftshift(k);

plot((1:length(S))/Fs, S);
xlabel('Time [sec]'); ylabel('Amplitude');
title('Mary had a little lamb (piano)'); drawnow
% p8 = audioplayer(S, Fs); playblocking(p8);



width = [1];
[Sgt_spec, k_c] = gabor_filter(width, S, Fs, t, ks);

function [Sgt_spec, k_c] = gabor_filter(width, S, Fs, t, ks)
    tslide = 0:0.5:(length(S)/Fs);
    Sgt_spec = [];
    k_c = [];
    for i = 1:length(width)
        for j = 1:length(tslide)
            g = exp(-width(i)*(t-tslide(j)).^2);
            Sg = g .* S'; Sgt = fft(Sg);
            Sgt_s = fftshift(Sgt);
            [~, idx] = max(abs(Sgt_s));
            idx = length(Sgt_s) - idx + 2;
            filter = exp(-0.2*(ks - ks(idx)).^2); 
            k_c = [k_c; ks(idx)];
            Sgt_f = filter .* Sgt_s;
            truncated_Sgt_f = Sgt_f((length(Sgt_f)/2+2):end);
            Sgt_spec = [Sgt_spec; abs(truncated_Sgt_f)];
            subplot(5, 1, 1), plot(t, S, 'k', t, g, 'r')
            subplot(5, 1, 2), plot(t, Sg, 'k')
            subplot(5, 1, 3), plot(ks, filter)
            subplot(5, 1, 4), plot(ks, abs(Sgt_f)/max(abs(Sgt_f)))
            axis([-1.5e5 1.5e5 -1.5 1.5])
            subplot(5, 1, 5), plot(ks, abs(Sgt_s)/max(abs(Sgt_s)))
            
            drawnow
            pause(0.01)
        end
    end
    figure
    pcolor(tslide, log(ks((length(ks)/2+2):end)), Sgt_spec.')
    shading interp
    set(gca, 'Fontsize', [14])
    colormap(hot)
end