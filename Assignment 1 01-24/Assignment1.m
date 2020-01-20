clear all; close all; clc;
load Testdata
L=15; % spatial domain
n=64; % Fourier modes
x2=linspace(-L,L,n+1); x=x2(1:n); y=x; z=x;
k=(2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; ks=fftshift(k);
[X,Y,Z]=meshgrid(x,y,z);
[Kx,Ky,Kz]=meshgrid(ks,ks,ks);
Utnp_avg = zeros(n, n, n);

% for j=1:20
% Un(:,:,:)=reshape(Undata(j,:),n,n,n);
% Utn = fftn(Un);
% Utnp = fftshift(Utn);
% Utnp_avg = Utnp_avg + Utnp;
% end
% 
% Utnp_avg = Utnp_avg / 20;
% fig_counter = 1;
% for level = 0.6:0.1:0.9
%     figure(fig_counter)
%     title(num2str(level))
%     axis([-7 7 -7 7 -7 7])
%     isosurface(Kx, Ky, Kz, abs(Utnp_avg)/abs(max(max(max(Utnp_avg)))), level)
%     xlabel('Kx'), ylabel('Ky'), zlabel('Kz')
%     fig_counter = fig_counter + 1;
% end

f_x = 2;
f_y = -1;
f_z = 0;

tau = 0.2;
filter = exp(-tau*((Kx - f_x).^2 + (Ky - f_y).^2 + (Kz - f_z).^2));

for j=1:20
Un(:,:,:)=reshape(Undata(j,:),n,n,n);
Utn = fftn(Un);
Utnp = fftshift(Utn);
Utnp_f = filter .* Utnp;
Unp_f = ifftn(fftshift(Utnp_f));
figure(1)

title("trajectory of the marble in the dog's intestine")
isosurface(X,Y,Z,abs(Unp_f)/abs(max(Unp_f(:))),0.975)
axis([-20 20 -20 20 -20 20]), grid on, drawnow
xlabel('x'), ylabel('y'), zlabel('z')
%pause(1)
end

[max, idx] = max(Unp_f(:));
x_coord = X(idx)
y_coord = Y(idx)
z_coord = Z(idx)

