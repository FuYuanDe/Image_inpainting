function [inpaintedImg,origImg,fillImg_org,C,D,fillMovie] = inpaint(imgFilename,fillFilename,fillColor)
%INPAINT  Exemplar-based inpainting.
%
% Usage:   [inpaintedImg,origImg,fillImg,C,D,fillMovie] ...
%                = inpaint(imgFilename,fillFilename,fillColor)
% Inputs: 
%   imgFilename    ԭʼͼ��.   
%   fillFilename   ָ�����޸������ͼ��. 
%   fillColor      Ϊ��ָ���޸��������RGB��������ʾ��һ����ɫ
% Outputs:
%   inpaintedImg   ˫���ȶȵ�M*N*3���޸����˵�ͼ��. 
%   origImg        ˫���ȶȵ�M*N*3��ԭʼͼ��.
%   fillImg        ˫���ȶȵ�M*N*3���������ͼ��.
%   C              ���ε����У�M*N�����Ŷ�ֵ�ľ���.
%   D              ���ε����У�M*N��������ֵ�ľ���.
%   fillMovie      չʾÿ�ε�������������.. 
%
% Example:
%   [i1,i2,i3,c,d,mov] = inpaint('21.png','22.png',[0 255 0]);
%  plotall;           % quick and dirty plotting script
%  close; movie(mov); % grab some popcorn 
%  author: Sooraj Bhat

warning off MATLAB:divideByZero %�رվ���
[img,fillImg_org,fillRegion,number_of_inpainted]= loadimgs(imgFilename,fillFilename,fillColor);%����ͼ���������ʹ�á�fillColor����Ϊ���ֵ�����˽�Ҫ�������ء�
imshow(fillRegion);
img = double(img);
origImg = img;  %˫���ȵ�ԭͼ��
ind = img2ind(img);  %����img2ind()���� ��RGBͼ��ת��Ϊ����ͼ��ʹ��ͼ������Ϊɫ��ͼ��
sz = [size(img,1) size(img,2)];%sz=[img���� img����] r=size(A,1)����䷵�ص�ʱ����A�������� c=size(A,2) ����䷵�ص�ʱ����A��������
sourceRegion = ~fillRegion;%~����һ�������ǰ�棬������ֻҪ��Ϊ0������ȡ��Ϊ0��ԭ����0��������1
fillImg=fillImg_org;%****************************************
% Initialize isophote values
[Ix(:,:,3) Iy(:,:,3)] = gradient(img(:,:,3)); %gradient()������ֵ�ݶȺ���������
%[Fx,Fy]=gradient(x)������FxΪ��ˮƽ�����ϵ��ݶȣ�FyΪ�䴹ֱ�����ϵ��ݶȣ�Fx�ĵ�һ��Ԫ��Ϊԭ����ڶ������һ��Ԫ��֮�
%Fx�ĵڶ���Ԫ��Ϊԭ������������һ��Ԫ��֮�����2���Դ����ƣ�Fx(i,j)=(F(i,j+1)-F(i,j-1))/2�����һ����Ϊ�������֮�ͬ�����Եõ�Fy��
[Ix(:,:,2) Iy(:,:,2)] = gradient(img(:,:,2));
[Ix(:,:,1) Iy(:,:,1)] = gradient(img(:,:,1));
Ix = sum(Ix,3)/(3*255); Iy = sum(Iy,3)/(3*255);%��ͼ��ΪRGB��ͨ��ʱ����sum(A,3)������ֵΪÿ��ͨ����Ӧλ�õ�ֵ�������
%imshow(Ix)
%imshow(Iy)
temp = Ix; Ix = -Iy; Iy = temp;  % Rotate gradient 90 degrees����ת�ݶ�90��

% Initialize confidence and data terms ��ʼ�����ŶȺ���������
C = double(sourceRegion);   
D = repmat(-.1,sz);   %�ظ������ظ���СΪsz�ľ���ÿ��ֵ����-0.1

% Visualization stuff���ӻ��Ķ���
if nargout==6    %nargout��������ĸ���
  fillMovie(1).cdata=uint8(img); 
  fillMovie(1).colormap=[];
  origImg(1,1,:) = fillColor;
  iter = 2;
end

% Seed 'rand' for reproducible results (good for testing)����'rand'���ظ��Ľ���������ڲ��ԣ�
rand('state',0);  %Resets the generator to its initial state.������������Ϊ��ʼ״̬��


    %% while any(fillRegion(:)) %any()����ʱΪ��
    
% Ѱ�ұ߽� &��һ�����������ݶ�
fill=find(fillRegion==1);
dR = find(conv2(single(fillRegion),[1,1,1;1,-8,1;1,1,1],'same')>0);  
%single������ɵ����ȵģ�                               
%conv2��a,b,'same'����ά���,���غ�aһ����С�ľ���
%find()�������������ľ�����Ԫ�ص����к�������������
%fillRegionԭͼ��С 
                                                                     
                                                                       
 [Nx,Ny] = gradient(1-fillRegion);
 N = [Nx(dR(:)) Ny(dR(:))];
 % imshow(N);
 N = normr(N);     %���й�һ�� 
 N(~isfinite(N))=0; % ���� NaN and Inf ��isfinite()����������Ԫ��Ϊ�������Ӧ1��Ԫ��Ϊ�������Ӧ0
  
 %---------------------------------------------
 %��������Ե�������Ŷ�
 %��ȡ��Ĵ�С����������ֵ
 %---------------------------------------------
  
    a=rgb2gray(fillImg);
    a=double(a);
    %fillRegion=double(fillRegion);
    BB1 = edge(a,'canny');
    BB=edge(fillRegion,'canny');

    BW=BB1-BB;
    imshow(BW);
    
 number_1=sum(sum(BW));
  ww=[];
  for k=dR'
     [Hp,rows,cols,w]= getpatch_auto(BW,k);      %����getpatch_auto()����
     q = Hp(~(fillRegion(Hp))); %fillRegion(Hp)��(2w+1)*(2w+1)�Ŀ飬��������������1��Դ������0
                                 %q������������Դ�������ص㹹��
     C(k) = sum(C(q))/numel(Hp);%numel()�����������
       %tt=numel(Hp);
     ww=[ww w];
  end
  
  % ����ֵ= confidence term * data term
  D(dR) = abs(Ix(dR).*N(:,1)+Iy(dR).*N(:,2)) + 0.00001;
  priorities = (C(dR)).* D(dR);   %������
  
     
  %�ҵ���������ֵ, Hp
     %[unused,ndx] = max(priorities(:));%max()�ҵ�ÿ���е����ֵ����unused���ڼ�������ndx
  priorities=priorities';%������
  [X,I]=sort(priorities);
  x=fliplr(X);    %�Ӵ�С�������ֵ
  ndx=fliplr(I);  %����ֵ��Ӧ����dR�е�˳��
     
  for i=1:size(dR,1)
      ww_order(i)=ww(ndx(i));
  end
  
  prior=priorities;
  
  dR=dR';   %������
  
  
  % ѭ��ֱ��ȫ���޸���

 while or(any(dR),any(fillRegion))
     
     %----------------------------------------------------------
     %�޸����ȼ���ߵĵ�
     %
     %----------------------------------------------------------

     p = dR(ndx(1));   %ȡdR�����ȼ����ĵ�
     w_max=ww_order(1);
     [Hp,rows,cols]= getpatch(fillImg,w_max,p);%rows������������cols����������
     toFill = fillRegion(Hp); %9*9��ֵ��
     qq = Hp(~(fillRegion(Hp)));
     %����ƥ��
     Hq = bestexemplar(img,img(rows,cols,:),toFill',sourceRegion);%����bestexemplar����
    
   
     % �����������
     fillRegion(Hp(toFill)) = false;   % ��HpΪ0����֪�� 
      
     %���º�ı�Ե�ݶ�
     [Nx,Ny] = gradient(1-fillRegion);  

     % Propagate confidence & isophote values
     
     rr=img(:,:,1);
     pp1=rr(qq);
     gg=img(:,:,2);
     pp2=gg(qq);
     bb=img(:,:,3);
     pp3=bb(qq);
     pp=(pp1+pp2+pp3)/3;
     
     C(Hp(toFill))  = C(p)*exp(-1*mse(pp));
%      C(Hp(toFill))  = C(p)
     Ix(Hp(toFill)) = Ix(Hq(toFill));
     Iy(Hp(toFill)) = Iy(Hq(toFill));
  
     % Copy image data from Hq to Hp
    ind(Hp(toFill)) = ind(Hq(toFill));
    img(rows,cols,:) = ind2img(ind(rows,cols),origImg);  
    fillImg(rows,cols,:)= ind2img(ind(rows,cols),origImg);  
   
    % Visualization stuff
    if nargout==6
       ind2=ind;
       ind2(fillRegion)= 1;
       fillMovie(iter).cdata=uint8(ind2img(ind2,origImg)); 
       fillMovie(iter).colormap=[];
    end      
     
    %---------------------------------------------------------
    %ȥ�������㣬�����µ����ص㣻������dR,x,ndx��ww��
    %---------------------------------------------------------
    
    dR_new_1=find(conv2(single(fillRegion),[1,1,1;1,-8,1;1,1,1],'same')>0);
    dR_new=dR_new_1'; %������
    compare_dR=ismember(dR,dR_new);%dR_new�е�Ԫ����dR�У���Ӧλ��Ϊ1������Ϊ0
   
    dR_notin_dR_new=[];
    
    for u=1:size(compare_dR,2)
        if compare_dR(u)==0
        dR_notin_dR_new=[dR_notin_dR_new u];
        end
    end
        
    dR(:,dR_notin_dR_new)=[];
    ww(:,dR_notin_dR_new)=[];
    prior(:,dR_notin_dR_new)=[];
    %����
    compare_dR_new=ismember(dR_new,dR);
    
    a=rgb2gray(fillImg); 
    a=double(a);

    BB1 = edge(a,'canny');

   if any(fillRegion(:)) 
      BB=edge(fillRegion,'canny');
   else BB=repmat(0,sz);
   end

    BW=BB1-BB;   %ѭ������
    
    figure(2);
%    imshow(BW);
    
    for  v=1:size(compare_dR_new,2)
       if compare_dR_new(v)==0
          new_index=dR_new(v);
          dR=[dR new_index];
            
             %��������ֵ
          [Hp,rows,cols,w]= getpatch_auto(BW,new_index);
            
          ww=[ww w];
            
          q = Hp(~(fillRegion(Hp)));%q ��֪��
          C(new_index)= sum(C(q))/numel(Hp);
            
             
          N = [Nx(new_index) Ny(new_index)];
          N = normr(N);     %���й�һ�� 
          N(~isfinite(N))=0;
          D(new_index)= abs(Ix(new_index)*N(1,1)+Iy(new_index)*N(1,2)) + 0.00001;
            
          p_new=C(new_index)*D(new_index);
              
          prior=[prior p_new];
       end
     end
    
      [X,I]=sort(prior);
      x=fliplr(X);    %�Ӵ�С�������ֵ
      ndx=fliplr(I);  %����ֵ��Ӧ����dR�е�˳��
     
      for i=1:size(dR,2)
         ww_order(i)=ww(ndx(i));
      end
     
    
  iter = iter+1;  
end

inpaintedImg=img;

fill_mse=[];

for i=3:-1:1 
    temp1=origImg(:,:,i); 
    temp2=inpaintedImg(:,:,i);
    uu=temp1(fill(:))-temp2(fill(:));
    fill_mse=[fill_mse mse(uu)]
end;




%---------------------------------------------------------------------
% Scans over the entire image (with a sliding window)
%ɨ������ͼ�񣨴��������ڣ�
% for the exemplar with the lowest error. Calls a MEX function.
%���ھ�����ʹ����ʾ���� ����MEX���ܡ�
%---------------------------------------------------------------------
function Hq = bestexemplar(img,Ip,toFill,sourceRegion)
m=size(Ip,1);n=size(Ip,2);mm=size(img,1); nn=size(img,2);
best = bestexemplarhelper(mm,nn,m,n,img,Ip,toFill,sourceRegion);
Hq = sub2ndx(best(1):best(2),(best(3):best(4))',mm);


%---------------------------------------------------------------------
% Returns the indices for a 9x9 patch centered at pixel p.
%����������pΪ���ĵ�9x9������������
%---------------------------------------------------------------------
function [Hp,rows,cols,w]=getpatch_auto(BW,p)
% [x,y] = ind2sub(sz,p);  % 2*w+1 == the patch size


sz=size(BW);

p=p-1;
y=floor(p/sz(1))+1;
p=rem(p,sz(1)); 
x=floor(p)+1;

number=0;
w=1;
while (number<3&&w<7)
    rows = max(x-w,1):min(x+w,sz(1));          %9*9�Ŀ� rows��������
    cols = (max(y-w,1):min(y+w,sz(2)))';       %cols��������

    MM = rows(ones(length(cols),1),:);% ones()��length(cols)*1��ȫ1������
    %imshow(X);title('x');          %X��9*9����ÿһ�е�Ԫ�ض�һ������������
    %[yy,ee]=size(X)
    NN = cols(:,ones(1,length(rows)));%Y��9*9����ÿһ�е�Ԫ�ض�һ������������
    N = MM+(NN-1)*sz(1);  %��������
    %figure(3);
    %imshow(N);
    %imshow(BW(N));
    %BW(N);

   [a b]=size(BW(N));
   BW2=reshape(BW(N),1,a*b);

    for k=1:a*b
      if BW2(k)==1
       number=number+1;
      end
    end
   
    w=w+1;
end  

 
 if number<8
      w=w-1;
 else w=w-2;
 end
                                                              
rows = max(x-w,1):min(x+w,sz(1));          %9*9�Ŀ� rows��������
cols = (max(y-w,1):min(y+w,sz(2)))';       %cols��������
Hp = sub2ndx(rows,cols,sz(1));     %����sub2ndx()


%---------------------------------------------------------------------
% Returns the indices for a w_max*w_max patch centered at pixel p.
%����������pΪ���ĵ�w_max * w_max������������
%---------------------------------------------------------------------

function [Hp,rows,cols]=getpatch(fillImg,w_max,p)
% [x,y] = ind2sub(sz,p);  % 2*w+1 == the patch size
sz=size(fillImg);
p=p-1; y=floor(p/sz(1))+1; p=rem(p,sz(1)); x=floor(p)+1;  %floor(x)С��x����������,rem(x,y)=x - n.*y, n=fix(x./y)=floor(x./y)
                                                               %x��p��������y��p������

rows = max(x-w_max,1):min(x+w_max,sz(1));          %9*9�Ŀ� rows��������
cols = (max(y-w_max,1):min(y+w_max,sz(2)))';       %cols��������
Hp = sub2ndx(rows,cols,sz(1));  



%---------------------------------------------------------------------
% Converts the (rows,cols) subscript-style indices to Matlab index-style
% indices.  Unforunately, 'sub2ind' cannot be used for this.
%����rows��cols���±���ʽ����ת��ΪMatlab������ʽ������ ���ҵ��ǣ�'sub2ind'�������ڴˡ�
%---------------------------------------------------------------------
function N = sub2ndx(rows,cols,nTotalRows)
X = rows(ones(length(cols),1),:);% ones()��length(cols)*1��ȫ1������
%imshow(X);title('x');          %X��9*9����ÿһ�е�Ԫ�ض�һ������������
%[yy,ee]=size(X)
Y = cols(:,ones(1,length(rows)));%Y��9*9����ÿһ�е�Ԫ�ض�һ������������
N = X+(Y-1)*nTotalRows;  %��������


%---------------------------------------------------------------------
% Converts an indexed image into an RGB image, using 'img' as a colormap
%������ͼ��ת��ΪRGBͼ��ʹ�á�img����Ϊɫ��ͼ��
%---------------------------------------------------------------------
function img2 = ind2img(ind,img)
for i=3:-1:1, temp=img(:,:,i); img2(:,:,i)=temp(ind); end;


%---------------------------------------------------------------------
% Converts an RGB image into a indexed image, using the image itself as
%��RGBͼ��ת��Ϊ����ͼ��ʹ��ͼ������Ϊɫ��ͼ��
% the colormap.
%---------------------------------------------------------------------
function ind = img2ind(img)
s=size(img); ind=reshape(1:s(1)*s(2),s(1),s(2));%1��s(1)*s(2)���и���s(1)��s(2)�еľ��󣬰��и�ֵ


%---------------------------------------------------------------------
% Loads the an image and it's fill region, using 'fillColor' as a marker
% value for knowing which pixels are to be filled.
%����ͼ���������ʹ�á�fillColor����Ϊ���ֵ�����˽�Ҫ�������ء�
%---------------------------------------------------------------------
function [img,fillImg,fillRegion,number_of_inpainted]= loadimgs(imgFilename,fillFilename,fillColor)
img = imread(imgFilename); fillImg = imread(fillFilename);
fillRegion = fillImg(:,:,1)==fillColor(1) & ...
    fillImg(:,:,2)==fillColor(2) & fillImg(:,:,3)==fillColor(3);
a=single(fillRegion);
number_of_inpainted=sum(sum(a))
rate=number_of_inpainted/(size(img,1)*size(img,2))