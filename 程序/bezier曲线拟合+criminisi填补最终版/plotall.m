% This is a simple script to plot some diagrams.����һ���򵥵Ļ�ͼ�ű�
% It assumes you have already run inpaint, storing into the variables i1,i2,i3,c,d, like so.�������Ѿ������,�洢������:
clear all;
[i1,i2,i3,c,d,mov]=inpaint('hello3.png','hello3.png',[0 255 0]);

figure(1);
image(uint8(i2)); title('ԭͼ��');
figure(2);
image(uint8(i3)); title('ѡ�����޸�����');
figure(3);
image(uint8(i1)); title('�޸����ͼ��');
% subplot(234);imagesc(c); title('���Ŷ�');
% subplot(235);imagesc(d); title('������');

figure(4);
image(uint8(i1)); title('�޸����ͼ��');
%figure;
%subplot(121);imagesc(c); title('Confidence term');
%subplot(122);imagesc(d); title('Data term');
imwrite(uint8(i1),'inpainted.png')
close;
figure(5);
movie(mov);