clear all;
close all;

fid = fopen('32_32_.txt','r');
C=[(fread(fid)-48).'].*6000;
%C=[randi([0,1],1,1024)].*6000;

n=size(C,2);
CData=C*2-6000;
%% Define Carrier
f=1024;
T=1/f;
fs=256;
Ts=1/fs;
M=2;
n=M*length(C);
t=0:1/f:1;
car=6000.*sin(2*pi*fs*t);

%% convert impulse data to square
tp=0:1/f:T;
sqdata=[];
for(i=1:length(C))
  for(j=1:length(tp)-1)
    sqdata=[sqdata CData(i)];
  end
end  
sqdata=[sqdata 0];
figure;
plot(sqdata,'r-');
hold on;
grid on;
plot(car,'g-');
hold on;



%%Modulation
msignal=sqdata.*car/6000;
figure,plot(msignal,'b-');


nf1=60; %常態衰減值
nf2=75;
nf3=300;
nf4=600;
nf5=2100;
nf6=2400;
nf7=6000;

%%%a=(square(2*pi*[0:127]/128).*6000); %sin %round=>四捨五入  振幅自定義
%%%an=round(a+(0.3*6000*randn(1,size(a,2))));
%fid = fopen('32_32_.txt','r');
%txttod=[(fread(fid)-48).'].*6000;
a=round(sqdata); %sin %round=>四捨五入  振幅自定義   %frequence=>6k(Hz) %7/25改成square
an=round(a+(0.1*6000*randn(1,size(a,2))));
%ap=(sin(2*pi/32*[0:255]).*6000);  這邊要想辦法改一下

%%bad_and_good

bg=4;% 134578

del1=23*bg;
del2=34*bg;
del3=50*bg;
del4=67*bg;
del5=86*bg;
del6=115*bg;

%ano=round(a+(0.1*6000*randn(1,size(a,2))));
%ano=round(nf7*(a+(0.05*randn(1,size(a,2)))));

if bg==0
  a1=round((nf7/6000)*([zeros(1,del1) a(1:size(a,2)-del1)]));
  amix=a1;
else  
  a1=round((nf6/6000)*([zeros(1,del1) a(1:size(a,2)-del1)]));
  a2=round((nf5/6000)*([zeros(1,del2) a(1:size(a,2)-del2)]));
  a3=round((nf4/6000)*([zeros(1,del3) a(1:size(a,2)-del3)]));
  a4=round((nf3/6000)*([zeros(1,del4) a(1:size(a,2)-del4)]));
  a5=round((nf2/6000)*([zeros(1,del5) a(1:size(a,2)-del5)]));
  a6=round((nf1/6000)*([zeros(1,del6) a(1:size(a,2)-del6)]));
  amix=(a1+a2+a3+a4+a5+a6);
end
figure,plot(a);



subplot(3,1,1);
plot(abs(fft(a)));
subplot(3,1,2);
plot(abs(fft(amix)))
subplot(3,1,3);
plot(abs(fft(amix)./fft(a))); 

%%%b=round(square(2*pi*[0:127]/128).*6000);  %cos   原本的32 %7/25改成square
%%%bn=round(b+(0.3*6000*randn(1,size(b,2))));

%nswave=round(randn(1,1025));
b=round(zeros(1,1025));  %cos   原本的32 %7/25改成square
bn=round(b+(0.1*6000*randn(1,size(b,2))));
%bn=round(b+(0.1*6000*randn(1,size(b,2))));
if bg==0
  b1=round((nf7/6000)*([zeros(1,del1) b(1:size(b,2)-del1)]));
  bmix=b1;
else  
  b1=round((nf6/6000)*([zeros(1,del1) b(1:size(b,2)-del1)]));
  b2=round((nf5/6000)*([zeros(1,del2) b(1:size(b,2)-del2)]));
  b3=round((nf4/6000)*([zeros(1,del3) b(1:size(b,2)-del3)]));
  b4=round((nf3/6000)*([zeros(1,del4) b(1:size(b,2)-del4)]));
  b5=round((nf2/6000)*([zeros(1,del5) b(1:size(b,2)-del5)]));
  b6=round((nf1/6000)*([zeros(1,del6) b(1:size(b,2)-del6)]));
  bmix=(b1+b2+b3+b4+b5+b6);
end
%figure,plot(b);
%c=amix+1i*bmix;

c=amix+1i*bmix;
figure,plot(amix);
figure,plot(c,'*');
figure,plot(amix,zeros(1,1025),'*');

%figure,plot(abs(fft(c)./fft(sqdata)));