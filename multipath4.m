clear all;
close all;

%% file in
fid = fopen('32_32_.txt','r');
txttod=[(fread(fid)-48).'].*6000;
txttod1=reshape((txttod'*ones(1,10))',1,size(txttod,2)*10);
CData=txttod1*2-6000;
%% Define Carrier
f=1024;
T=1/f;
fs=256;
Ts=1/fs;
M=2;
n=M*length(txttod1);
t=0:1/f:1;
car=6000.*sin(2*pi*fs*t);

%% convert impulse data to square
tp=0:1/f:T;
sqdata=[];
for(i=1:length(txttod1))
  for(j=1:length(tp)-1)
    sqdata=[sqdata CData(i)];
  end
end  
sqdata=[sqdata];
figure;
plot(sqdata,'r-');
%hold on;
%grid on;
%plot(car,'g-');
%hold on;
%% Modulation
%msignal=sqdata.*car/6000;
%figure;
%plot(msignal,'b-');



%%Modulation
%msignal=sqdata.*car/6000;
%figure;
%plot(msignal,'b-');


nf1=60; %常態衰減值
nf2=75;
nf3=100;
nf4=2700;
nf5=4500;
nf6=5400;
nf7=6000;

%%%a=(square(2*pi*[0:127]/128).*6000); %sin %round=>四捨五入  振幅自定義

a=round(sqdata); %sin %round=>四捨五入  振幅自定義   %frequence=>6k(Hz) %7/25改成square
an=round(a+(0.1*6000*randn(1,size(a,2))));
%ap=(sin(2*pi/32*[0:255]).*6000);  這邊要想辦法改一下

%% let it bad_and_good
bg=100; %delaytime

del1=round(1*bg);
del2=round(2*bg);
del3=round(3*bg);


%ano=round(a+(0.1*6000*randn(1,size(a,2))));
%ano=round(nf7*(a+(0.05*randn(1,size(a,2)))));
if bg==0
  a1=round((nf7/6000)*([zeros(1,del1) an(1:size(an,2)-del1)]));
  amix=a1;
else   
  a1=round((nf6/6000)*([zeros(1,del1) an(1:size(an,2)-del1)]));
  a2=round((nf5/6000)*([zeros(1,del2) an(1:size(an,2)-del2)]));
  a3=round((nf4/6000)*([zeros(1,del3) an(1:size(an,2)-del3)]));
  
  amix=(a1+a2+a3);
end
%figure;
%subplot(3,1,1);
%plot(abs(fft(a)));
%subplot(3,1,2);
%plot(abs(fft(amix)))
%subplot(3,1,3);
%plot(abs(fft(amix)./fft(a))); 
%plot(abs(fft(amix)./fft(a(1:127))./fft(a(128,255)))) %要改

%%%b=round(square(2*pi*[0:127]/128).*6000);  %cos   原本的32 %7/25改成square
%%%bn=round(b+(0.3*6000*randn(1,size(b,2))));

%% Noise image
ns=round(zeros(1,10240));
b=round(ns);  %cos   原本的32 %7/25改成square
bn=round(b+(0.1*6000*randn(1,size(b,2))));
%bn=round(b+(0.1*6000*randn(1,size(b,2))));

if bg==0
    b1=round((nf7/6000)*([zeros(1,del1) bn(1:size(bn,2)-del1)]));
    bmix=b1;
else
b1=round((nf6/6000)*([zeros(1,del1) bn(1:size(bn,2)-del1)]));
b2=round((nf5/6000)*([zeros(1,del2) bn(1:size(bn,2)-del2)]));
b3=round((nf4/6000)*([zeros(1,del3) bn(1:size(bn,2)-del3)]));

bmix=(b1+b2+b3);
end
%c=amix+1i*bmix;
c=amix+1i*bmix;

%plus the multipath => i use c to delay a time
%c1=[zeros(0,20) c(1:size(c,2)-20)];
figure,plot(c/6000,'*');
view(-90,90)
xlim([-2.5 2.5]);
figure,subplot(2,1,1);
plot(a);
subplot(2,1,2);
plot(amix);
figure,plot(amix);

%figure,plot(abs(fft(c)./fft(sqdata)));