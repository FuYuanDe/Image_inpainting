clear all;
color=imread('hello3.png');
%color=imcrop(color,[6 5 324 296]);%�ָ�ͼ��
imshow(color);
aa = input('������ʹ��1�׻���2��bezier����:(0 to quit)');
while 0~=aa
    if aa==1
         x1=input('����x1:');y1=input('����y1:');
         x2=input('����x2:');y2=input('����y2:');
         for t1=x1:1:x1+3
             for t2=x2:1:x2+3
            color=one_level_bezier(color,t1,y1,t2,y2);
             end;
         end;
         t1=t1-3;
         t2=t2-3;
         for t1=x1:-1:x1-3
             for t2=x2:-1:x2-3
             color=one_level_bezier(color,t1,y1,t2,y2);
             end;
         end;
         imshow(color);
    else
         aaa=input('�Ƿ�֪�����Ƶ㣨1֪��2��֪����:');
         if aaa==1
             x1=input('����x1:');y1=input('����y1:');
             x2=input('����x2:');y2=input('����y2:');
             x3=input('����x3:');y3=input('����y3:');
             for m=x1:1:x1+1
                 x2=x2+1;
                 x3=x3+1;
                 color=two_level_bezier(color,m,y1,x2,y2,x3,y3);
             end;
             m=m-1;
             x2=x2-1;
             x3=x3-1;
             for m=x1:-1:x1-1
                 x2=x2-1;
                 x3=x3-1;
                 color=two_level_bezier(color,m,y1,x2,y2,x3,y3);
             end;
             imshow(color);
         else
             x1=input('����x1:');y1=input('����y1:');
             x2=input('����x2:');y2=input('����y2:');
             x3=input('����x3:');y3=input('����y3:');
             x4=input('����x4:');y4=input('����y4:');
              for z=x1:1:x1+1
                 x2=x2+1;
                 x3=x3+1;
                 x4=x4+1;
                 color=two_level_bezier4(color,z,y1,x2,y2,x3,y3,x4,y4);
             end;
             z=z-1;
             x2=x2-1;
             x3=x3-1;
             x4=x4-1;
             for z=x1:-1:x1-1
                 x2=x2-1;
                 x3=x3-1;
                 x4=x4-1;
                 color=two_level_bezier4(color,z,y1,x2,y2,x3,y3,x4,y4);
             end;
             imshow(color);
         end
    end    
    aa = input('������ʹ��1�׻���2��bezier����:(0 to quit)');
end
%figure;
%imshow('blacktest.png');
imwrite(color,'hello3.png');