clear all; close all; clc;
load Testdata
L=15; % spatial domain
n=64; % Fourier modes
x2=linspace(-L,L,n+1); x=x2(1:n); y=x; z=x;
k=(2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; ks=fftshift(k);
[X,Y,Z]=meshgrid(x,y,z);
[Kx,Ky,Kz]=meshgrid(ks,ks,ks);
Utnp_avg = zeros(n, n, n);

for j=1:20
Un(:,:,:)=reshape(Undata(j,:),n,n,n);
Utn = fftn(Un);
Utnp = fftshift(Utn);
Utnp_avg = Utnp_avg + Utnp;
end

Utnp_avg = Utnp_avg / 20;
% fig_counter = 1;
% for level = 0.1:0.1:0.9
%     figure(fig_counter)
%     axis([-7 7 -7 7 -7 7])
%     isosurface(Kx, Ky, Kz, abs(Utnp_avg)/abs(max(Utnp_avg(:))), level);
%     view(30,-15)
%     xlabel('Kx'), ylabel('Ky'), zlabel('Kz')
%     set(gcf,'color','w');
%     imagewd = getframe(gcf);
%     imwrite(imagewd.cdata, num2str(fig_counter)+".jpeg", "Quality", 100);
%     fig_counter = fig_counter + 1;
% end

f_x = 2;
f_y = -1;
f_z = 0;

tau = 0.2;
filter = exp(-tau*((Kx - f_x).^2 + (Ky - f_y).^2 + (Kz - f_z).^2));

x_coord = zeros(1, 20);
y_coord = zeros(1, 20);
z_coord = zeros(1, 20);

for j=1:20
Un(:,:,:)=reshape(Undata(j,:),n,n,n);
Utn = fftn(Un);
Utnp = fftshift(Utn);
Utnp_f = filter .* Utnp;
Unp_f = ifftn(fftshift(Utnp_f));
[~, idx] = max(Unp_f(:));
x_coord(j) = X(idx);
y_coord(j) = Y(idx);
z_coord(j) = Z(idx);
end

figure(1)
plot3(x_coord, y_coord, z_coord, 'o')
hold on
plot3(x_coord, y_coord, z_coord)
hold on 
plot3([x_coord(end), x_coord(end)], [y_coord(end), y_coord(end)], [z_coord(end), -20], '--k')
plot3([x_coord(end), x_coord(end)], [y_coord(end), 20], [z_coord(end), z_coord(end)], '--k')
plot3([x_coord(end), -20], [20, 20], [z_coord(end), z_coord(end)], '--k')
plot3([x_coord(end), x_coord(end)], [y_coord(end), -20], [-20, -20], '--k')
plot3([x_coord(end), -20], [y_coord(end), y_coord(end)], [-20, -20], '--k')
axis([-20 20 -20 20 -20 20]), grid on, drawnow
xlabel('x'), ylabel('y'), zlabel('z')

xf_coord = x_coord(20)
yf_coord = y_coord(20)
zf_coord = z_coord(20)

