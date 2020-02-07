clear, clc, close all

figure(1)
tr_rec = 14;
S2 = audioread('music2.wav'); Fs2 = length(S2)/tr_rec;
t2 = (1:length(S2))/Fs2; 
L2 = length(S2)/Fs2; n2 = length(S2);
k2 = (2*pi/L2)*[0:n2/2-1 -n2/2:-1]; ks2 = fftshift(k2);
plot((1:length(S2))/Fs2, S2);
xlabel('Time [sec]'); ylabel('Amplitude');
title('Mary had a little lamb (recorder)');
% p8 = audioplayer(S, Fs); playblocking(p8);

figure(2)
tr_piano = 16;
S1 = audioread('music1.wav'); Fs1 = length(S1)/tr_piano;
t1 = (1:length(S1))/Fs1; 
L1 = length(S1)/Fs1; n1 = length(S1);
k1 = (2*pi/L1)*[0:n1/2-1 -n1/2:-1]; ks1 = fftshift(k1);

plot((1:length(S1))/Fs1, S1);
xlabel('Time [sec]'); ylabel('Amplitude');
title('Mary had a little lamb (piano)'); drawnow
p8 = audioplayer(S1, Fs1); playblocking(p8);



width = [50];

figure(3)
y_lower = 0;
y_upper = 1000;
[Sgt_spec_1, k_c_1] = gabor_filter(width, S1, Fs1, t1, ks1, y_lower, y_upper);
figure(4)
y_lower = 600;
y_upper = 2100;
[Sgt_spec_2, k_c_2] = gabor_filter(width, S2, Fs2, t2, ks2, y_lower, y_upper);

function [Sgt_spec, k_c] = gabor_filter(width, S, Fs, t, ks, y_lower, y_upper)
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
            filter = linspace(1, 1, length(S));
            k_c = [k_c; ks(idx)];
            Sgt_f = filter .* Sgt_s;
            truncated_Sgt_f = Sgt_f((length(Sgt_f)/2+2):end);
            Sgt_spec = [Sgt_spec; abs(truncated_Sgt_f)];
            %subplot(5, 1, 1), plot(t, S, 'k', t, g, 'r')
%             subplot(5, 1, 2), plot(t, Sg, 'k')
%             subplot(5, 1, 3), plot(ks, filter)
%             subplot(5, 1, 4), plot(ks, abs(Sgt_f)/max(abs(Sgt_f)))
%             axis([-1.5e5 1.5e5 -1.5 1.5])
%             subplot(5, 1, 5), plot(ks, abs(Sgt_s)/max(abs(Sgt_s)))
%             
%             drawnow
%             pause(0.01)
        end
    end
    w = ks/(2*pi);
    pcolor(tslide, w((length(w)/2+2) : end), Sgt_spec.')
    axis([0 t(end) y_lower y_upper])
    xlabel("time (s)")
    ylabel("frequency (Hz)")
    shading interp
    set(gca, 'Fontsize', [14])
    hold on
    plot([15.5, 16], [261.63, 261.63], '-r')
    plot([15.5, 16], [293.66, 293.66], '-r')
    plot([15.5, 16], [329.63, 329.63], '-r')
    colormap(pink)
end