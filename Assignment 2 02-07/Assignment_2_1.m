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

% width = [10]
% for i = 1:length(width)
%     t = linspace(-100, 100, 201);
%     plot(t, 2/(sqrt(3*width(i)) * pi ^(1/4)) .* (1 - ((t-20)/width(i)).^2) .* exp(-(t-20).^2 / (2*width(i)^2)))
%     hold on
% end

% figure()
% width_2 = 5
% tslide = 0:0.1:(length(S)/Fs);
% t = linspace(0, 100, length(tslide));
% 
% for j = 1:length(tslide)
%     sw_filter = [zeros(1, j) ones(1, width_2) zeros(1, length(tslide) - j - width_2)];
%     plot(t, sw_filter)
%     drawnow
%     pause(0.1)
% end


% using different window width and sampling rate
% width = [0.1, 1, 10, 100];
% 
% for i = 1:length(width)
%     tslide_1 = 0:0.1:(length(S)/Fs);
%     % tslide_2 = 0:0.3:(length(S)/Fs); 
%     % tslide_3 = 0:1:(length(S)/Fs);
%     % tslide_4 = 0:3:(length(S)/Fs);
%     Sgt_spec = create_spectrogram([], "gaussian", width(i), t, tslide_1, S, ks);
%     % Sgt_spec = create_spectrogram([], "gaussian", width(i), t, tslide_2, S, ks);
%     % Sgt_spec = create_spectrogram([], "gaussian", width(i), t, tslide_3, S, ks);
%     % Sgt_spec = create_spectrogram([], "gaussian", width(i), t, tslide_4, S, ks);
% end

% using different filters
tslide_1 = 0:0.1:(length(S)/Fs);
Sgt_spec_gaussian = create_spectrogram([], "gaussian", 10, t, tslide_1, S, ks);
Sgt_spec_mexican_hat = create_spectrogram([], "mexican_hat", 0.3, t, tslide_1, S, ks);
Sgt_spec_shannon = create_spectrogram([], "shannon", 1, t, tslide_1, S, ks);

function [Sgt_spec] = create_spectrogram(Sgt_spec, filter, width, t, tslide, S, ks)
    for j = 1:length(tslide)
        if filter == "gaussian"
            g = exp(-width * (t-tslide(j)).^2);
        elseif filter == "mexican_hat"
            g = 2/(sqrt(3*width) * pi ^(1/4)) .* (1 - ((t- tslide(j))/width).^2) .* exp(-(t-tslide(j)).^2/(2*width^2));
            max_g = max(g);
            g = g/max_g;
        elseif filter == "shannon"
            factor = floor(length(t) / length(tslide));
            g = [zeros(1, j * factor) ones(1, floor(length(t)/10)) zeros(1, length(t) - floor(length(t)/10) - j * factor)];
            g = g(1:length(t));
        end
        
        Sg = g .* S; Sgt = fft(Sg);
        Sgt_f = abs(fftshift(Sgt));
        Sgt_spec = [Sgt_spec; Sgt_f(length(Sgt)/2 + 1: end)];
        %subplot(3, 1, 1), plot(t, S, 'k', t, g, 'r')
        %subplot(3, 1, 2), plot(t, Sg, 'k')
        %subplot(3, 1, 3), plot(ks, abs(fftshift(Sgt))/max(abs(Sgt)))
        %drawnow
        %pause(0.1)
        
%         if j == length(tslide) / 2
%             plot(t, S, 'k', t, g, 'r')
%             xlabel("Time (s)")
%             ylabel("Normalized Signal Intensity")
%             axis([0 9 -0.5 1])
%             set(gca, 'Fontsize', [16])
%         end
    end
    
    figure()
    pcolor(tslide, ks((length(ks)/2 + 1):end)/(2*pi), Sgt_spec.')
    %title("Spectrogram of Handel (a = " + num2str(width) + ", resolution = " + int2str(length(tslide)) + ")", "fontSize", 10)
    xlabel("Time (second)", "FontSize", 18)
    ylabel("Frequency (Hz)", "FontSize", 18)
    shading interp
    set(gca, 'Fontsize', [16])
    colormap(hot)
end