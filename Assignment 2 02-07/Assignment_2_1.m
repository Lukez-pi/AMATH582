clear, clc, close all
load handel
S = (y(1:end-1))' / 2;
t = (1:length(S))/Fs;
L = length(S)/Fs;
n = length(S);
k = (2*pi/L)*[0:n/2-1 -n/2:-1];
ks = fftshift(k);
plot(t, S);
xlabel('Time [sec]')
ylabel('Amplitude');
title('Signal of Interest, S(n)')

% p8 = audioplayer(S, Fs);
% playblocking(p8);

width = [10];
tslide = 0:0.1:(length(S)/Fs);
Sgt_spec = [];
for i = 1:length(width)
    for j = 1:length(tslide)
        g = exp(-width(i)*(t-tslide(j)).^2);
        Sg = g .* S; Sgt = fft(Sg);
        Sgt_spec = [Sgt_spec; abs(fftshift(Sgt))];
        subplot(3, 1, 1), plot(t, S, 'k', t, g, 'r')
        subplot(3, 1, 2), plot(t, Sg, 'k')
        subplot(3, 1, 3), plot(ks, abs(fftshift(Sgt))/max(abs(Sgt)))
        
        drawnow
        pause(0.1)
    end
end
figure
pcolor(tslide, ks, Sgt_spec.'),
shading interp
set(gca, 'Fontsize', [14])
colormap(hot)