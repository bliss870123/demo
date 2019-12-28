clc;
clear all;
close all;
%% open control port
ctrl_link = udp('192.168.1.10', 5006);
fopen(ctrl_link);
%% open data port
data_link = tcpip('192.168.1.10', 5005);
set(data_link,'InputBufferSize',16*1024*1024);
set(data_link,'OutputBufferSize',64*1024*1024);
fopen(data_link);

%% ************************************
ref_hex=dec2hex(0,8);%1=external ref 0=internal ref %% "8"���F�A�������ǿ��ƪ��榡�n�D�A�ഫ��8��16�i���
vco_cal_hex=dec2hex(1,8);%1=auxdac 0=reference clock %% "8"���F�A�������ǿ��ƪ��榡�n�D�A�ഫ��8��16�i���
aux_dac1_hex=dec2hex(0,8);
fdd_tdd_hex=dec2hex(1,8);%%1:FDD 2:TDD
trx_sw_hex=dec2hex(1,8);%%1:TX 2:RX
%% ************************************
bw_hex=dec2hex(20e6,8);
samp_hex=dec2hex(1e2,8); %e�令1M(Hz)
freq_hex=dec2hex(900e6,10); %%for ad9361  %�令900M(Hz)
tx_att1=dec2hex(200,8);
tx_att2=dec2hex(200,8);
tx_chan=3;%1=tx1;2=tx2;3=tx1&tx2
%% generate tone signal
%x=randi([0 127]); %0~127�H�����ͤ@�Ӽ�
%y=randi([0 127]);
nf1=60; %�`�A�I���
nf2=75;
nf3=300;
nf4=600;
nf5=2100;
nf6=2400;
nf7=6000;

%%%a=(square(2*pi*[0:127]/128).*6000); %sin %round=>�|�ˤ��J  ���T�۩w�q
%%%an=round(a+(0.3*6000*randn(1,size(a,2))));
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
%% Noise image
ns=round(zeros(1,10240));
%% fading channel 
a=round(sqdata); %sin %round=>�|�ˤ��J  ���T�۩w�q   %frequence=>6k(Hz) %7/25�令square
an=round(a+(0.1*6000*randn(1,size(a,2))));
%ap=(sin(2*pi/32*[0:255]).*6000);  �o��n�Q��k��@�U

%del1=130;
%del2=150;
%del3=180;
%del4=210;
%del5=230;
%del6=250;

%% let it bad_and_good
bg=0; %34578

del1=round(23*bg);
del2=round(34*bg);
del3=round(50*bg);
del4=round(67*bg);
del5=round(86*bg);
del6=round(115*bg);

%ano=round(a+(0.1*6000*randn(1,size(a,2))));
%ano=round(nf7*(a+(0.05*randn(1,size(a,2)))));
if bg==0
a1=round((nf7/6000)*([zeros(1,del1) a(1:size(a,2)-del1)]));
amix=a1;
else   
a1=round((nf6/6000/bg)*([zeros(1,del1) a(1:size(a,2)-del1)]));
a2=round((nf5/6000/bg)*([zeros(1,del2) a(1:size(a,2)-del2)]));
a3=round((nf4/6000/bg)*([zeros(1,del3) a(1:size(a,2)-del3)]));
a4=round((nf3/6000/bg)*([zeros(1,del4) a(1:size(a,2)-del4)]));
a5=round((nf2/6000/bg)*([zeros(1,del5) a(1:size(a,2)-del5)]));
a6=round((nf1/6000/bg)*([zeros(1,del6) a(1:size(a,2)-del6)]));
amix=(a1+a2+a3+a4+a5+a6);

end
%figure;
%subplot(3,1,1);
%plot(abs(fft(a)));
%subplot(3,1,2);
%plot(abs(fft(amix)))
%subplot(3,1,3);
%plot(abs(fft(amix)./fft(a))); 
%plot(abs(fft(amix)./fft(a(1:127))./fft(a(128,255)))) %�n��

%%%b=round(square(2*pi*[0:127]/128).*6000);  %cos   �쥻��32 %7/25�令square
%%%bn=round(b+(0.3*6000*randn(1,size(b,2))));
b=round(ns);  %cos   �쥻��32 %7/25�令square
bn=round(b+(0.1*6000*randn(1,size(b,2))));
%bn=round(b+(0.1*6000*randn(1,size(b,2))));

if bg==0
    b1=round((nf7/6000)*([zeros(1,del1) b(1:size(b,2)-del1)]));
    bmix=b1;
else
b1=round((nf6/6000/bg)*([zeros(1,del1) b(1:size(b,2)-del1)]));
b2=round((nf5/6000/bg)*([zeros(1,del2) b(1:size(b,2)-del2)]));
b3=round((nf4/6000/bg)*([zeros(1,del3) b(1:size(b,2)-del3)]));
b4=round((nf3/6000/bg)*([zeros(1,del4) b(1:size(b,2)-del4)]));
b5=round((nf2/6000/bg)*([zeros(1,del5) b(1:size(b,2)-del5)]));
b6=round((nf1/6000/bg)*([zeros(1,del6) b(1:size(b,2)-del6)]));
bmix=(b1+b2+b3+b4+b5+b6);
end
%c=amix+1i*bmix;
c=amix+1i*bmix;

%plus the multipath => i use c to delay a time
%c1=[zeros(0,20) c(1:size(c,2)-20)];
figure,plot(c/2500,zeros(1,10240),'*');
xlim([-2.5 2.5]);
figure,subplot(2,1,1);plot(a);subplot(2,1,2);plot(amix);

txdata=repmat(c,1,8); 
%% copy to 2chanel
if tx_chan==1 || tx_chan==2
    txdata2=txdata;
elseif tx_chan==3
    txdata2=zeros(1,length(txdata)*2);
    txdata2(1:2:end)=txdata;
    txdata2(2:2:end)=txdata;
end
%% iq mux
txdatas=zeros(1,length(txdata2)*2);
txdatas(1:2:end)=real(txdata2);
txdatas(2:2:end)=imag(txdata2);
%% add pad
rem=-1;
i=0;
while (rem<0)
    rem=1024*2^i-length(txdatas);
    i=i+1;
end
txdata1=[txdatas zeros(1,rem)];
txd1=(txdata1<0)*65536+txdata1;
txd2=dec2hex(txd1,4);
txd3=txd2(:,1:2);
txd4=txd2(:,3:4);
txd5=hex2dec(txd3);
txd6=hex2dec(txd4);
txd7=zeros(length(txd6)*2,1);
txd7(1:2:end)=txd6;
txd7(2:2:end)=txd5;

%% tx bandwidth rate
bw=[0 7 hex2dec('22') hex2dec('f0') hex2dec(bw_hex(7:8)) hex2dec(bw_hex(5:6)) hex2dec(bw_hex(3:4)) hex2dec(bw_hex(1:2))];
fwrite(ctrl_link,bw,'uint8');
%% tx samp rate
samp=[0 5 hex2dec('22') hex2dec('f0') hex2dec(samp_hex(7:8)) hex2dec(samp_hex(5:6)) hex2dec(samp_hex(3:4)) hex2dec(samp_hex(1:2))];
fwrite(ctrl_link,samp,'uint8');
%% send tx freq set cmd
tx_freq=[hex2dec(freq_hex(1:2)) 3 hex2dec('22') hex2dec('f0') hex2dec(freq_hex(9:10)) hex2dec(freq_hex(7:8)) hex2dec(freq_hex(5:6)) hex2dec(freq_hex(3:4))];
fwrite(ctrl_link,tx_freq,'uint8');
%% send tx vga set cmd
tx_vga=[0 9 hex2dec('22') hex2dec('f0') hex2dec(tx_att1(7:8)) hex2dec(tx_att1(5:6)) hex2dec(tx_att1(3:4)) hex2dec(tx_att1(1:2))];  %TX1
fwrite(ctrl_link,tx_vga,'uint8');
tx_vga=[0 11 hex2dec('22') hex2dec('f0') hex2dec(tx_att2(7:8)) hex2dec(tx_att2(5:6)) hex2dec(tx_att2(3:4)) hex2dec(tx_att2(1:2))]; %TX2
fwrite(ctrl_link,tx_vga,'uint8');
%% send tx channel set cmd

channel=[tx_chan 0 hex2dec('20') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link,channel,'uint8');

%% **********************************************************
% �p�G�O��O���o���աA����brx.m���S���n�A�t�m�H�U�ѼơA�p�G�u�����o�A�h�brx.m���n�K�[�H�U�t�m
%% custom rf control command
rcount =dec2hex(10,4);
ncount = dec2hex(26,4);
% spi_data = dec2hex((rcount<<16)|ncount,8);
% % spi
spi=[0 40 hex2dec('18') hex2dec('f0') hex2dec(ncount(3:4)) hex2dec(rcount(1:2)) hex2dec(rcount(3:4)) hex2dec(rcount(1:2))];
if hex2dec(vco_cal_hex) == 0
   fwrite(ctrl_link,spi,'uint8');
end

% ref_select
ref_select=[0 40 hex2dec('22') hex2dec('f0') hex2dec(ref_hex(7:8)) hex2dec(ref_hex(5:6)) hex2dec(ref_hex(3:4)) hex2dec(ref_hex(1:2))];
fwrite(ctrl_link,ref_select,'uint8');
% vco_cal_select
vco_cal_select=[0 41 hex2dec('22') hex2dec('f0') hex2dec(vco_cal_hex(7:8)) hex2dec(vco_cal_hex(5:6)) hex2dec(vco_cal_hex(3:4)) hex2dec(vco_cal_hex(1:2))];
fwrite(ctrl_link,vco_cal_select,'uint8');
% fdd_tdd_select
fdd_tdd_select=[0 42 hex2dec('22') hex2dec('f0') hex2dec(fdd_tdd_hex(7:8)) hex2dec(fdd_tdd_hex(5:6)) hex2dec(fdd_tdd_hex(3:4)) hex2dec(fdd_tdd_hex(1:2))];
fwrite(ctrl_link,fdd_tdd_select,'uint8');
% trx_sw
trx_sw=[0 43 hex2dec('22') hex2dec('f0') hex2dec(trx_sw_hex(7:8)) hex2dec(trx_sw_hex(5:6)) hex2dec(trx_sw_hex(3:4)) hex2dec(trx_sw_hex(1:2))];
fwrite(ctrl_link,trx_sw,'uint8');

% aux_dac1
aux_dac1=[0 44 hex2dec('22') hex2dec('f0') hex2dec(aux_dac1_hex(7:8)) hex2dec(aux_dac1_hex(5:6)) hex2dec(aux_dac1_hex(3:4)) hex2dec(aux_dac1_hex(1:2))];

if hex2dec(vco_cal_hex) == 1
    fwrite(ctrl_link,aux_dac1,'uint8');
end
%% ***************************************************************
%% send handshake cmd
handshake=[2 0 hex2dec('16') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link ,handshake, 'uint8');
pause(0.5);
%% send handshake2 cmd  (�q��PS�n�o�e����ƶq)
data_length = dec2hex((2^(i-1)*2)*1024,8);
handshake=[2 0 hex2dec('17') hex2dec('f0') hex2dec(data_length(7:8)) hex2dec(data_length(5:6)) hex2dec(data_length(3:4)) hex2dec(data_length(1:2))];
fwrite(ctrl_link ,handshake, 'uint8');

%% Write data to the zing and read from the host.
fwrite(data_link,txd7,'uint8');
% pause(10);
% %% send handshake2 cmd to stop adc thread (�ΥH����TX loop�u�{)
% handshake=[hex2dec('ff') 0 hex2dec('17') hex2dec('f0') 0 0 0 0];
% fwrite(ctrl_link,handshake,'uint8');
%% close all link
fclose(data_link);
delete(data_link);
clear data_link;
fclose(ctrl_link);
delete(ctrl_link);
clear ctrl_link;

disp('data tansfer done');

