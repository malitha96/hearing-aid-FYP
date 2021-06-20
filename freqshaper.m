function y_shaped = freqshaper(x,fs,h_th,p_th,Lower_limit,Upper_limit,a)

% x - an input sound signal
% fs - the sampling frequency of the input signal
% h_th - Threshold of hearing
% p_th - Threshold of pain
% Lower_limit - Lower limit of the hearing loss range
% Upper_limit - Upper limit of the hearing loss range
% a - 

first = Lower_limit/2;
second = Lower_limit;
third = Upper_limit;
fourth = Upper_limit + (fs/2 - Upper_limit)/2;

x_length = length(x);
n = nextpow2(x_length);
N = 2^n;
T = 1/fs;
X = fft(x,N);
Y_shaped = zeros(N,1);
gain = zeros(N,1);

% Sets the gain for the first stage of frequencies
firstC = (.3*(h_th-1))/first;
k=0;
while(k/N <= first/fs)
   gain(k+1)= db2mag(1)+exp((k/(N*T)-first/2)/(first/5));
   gain(N-k) = gain(k+1);
   Y_shaped(k+1)=X(k+1)*gain(k+1);
   Y_shaped(N-k)=X(N-k)*gain(N-k);
   if abs(Y_shaped(k+1))>p_th          
      Y_shaped(k+1)=p_th;
      Y_shaped(N-k)=p_th;
   end
   k=k+1;
end;

% Sets the gain for the second stage of frequencies
secondC = db2mag(1)+exp(5/2);    
secondC2 = (second-first)/5;
while(k/N <= second/fs)
   %gain(k+1) = db2mag(1) + (secondC-1)*exp(-((k/(N*T))-first)/secondC2);
   gain(k+1) = h_th + (secondC-h_th)*exp(-((k/(N*T)-first))/secondC2);
   gain(N-k) = gain(k+1);
   Y_shaped(k+1)=X(k+1)*gain(k+1);
   Y_shaped(N-k)=X(N-k)*gain(N-k);
   if abs(Y_shaped(k+1))>p_th          
      Y_shaped(k+1)=p_th;
      Y_shaped(N-k)=p_th;
   end
   k=k+1;
end;

% Sets the gain for the third stage of frequencies
%thirdC = db2mag(1) + (secondC-1)*exp(-second/secondC2);  
thirdC2 = (third-second)/5;
while(k/N <= third/fs)
  % gain(k+1) = h_th + (thirdC-g)*exp(-((k/(N*T)-second))/thirdC2);
   gain(k+1)=h_th;
   gain(N-k) = gain(k+1);
   Y_shaped(k+1)=X(k+1)*gain(k+1);
   Y_shaped(N-k)=X(N-k)*gain(N-k);
   if abs(Y_shaped(k+1))>p_th          
      Y_shaped(k+1)=p_th;
      Y_shaped(N-k)=p_th;
   end
   k=k+1;
end;

fourthC=h_th;
fourthC2=(fourth-third)/5;
% Sets the gain for the fourth stage of frequencies
while(k/N <= fourth/fs)
   gain(k+1)= h_th-(fourthC/4-1)*exp((k/(N*T)-fourth)/(fourthC2));
   %gain(k+1) = h_th;
   gain(N-k) = gain(k+1);
   Y_shaped(k+1)=X(k+1)*gain(k+1);
   Y_shaped(N-k)=X(N-k)*gain(N-k);
   if abs(Y_shaped(k+1))>p_th          
      Y_shaped(k+1)=p_th;
      Y_shaped(N-k)=p_th;
   end
   k=k+1;
end;

% Sets the gain for the fifth stage of frequencies
fifthC = (3*h_th/4)+1;                
fifthC2 = (fs/2-fourth)/5;
while(k/N <= .5)
   gain(k+1) =db2mag(1) + (fifthC-1)*exp(-((k/(N*T))-fourth)/fifthC2);
   gain(N-k) = gain(k+1);
   Y_shaped(k+1)=X(k+1)*gain(k+1);
   Y_shaped(N-k)=X(N-k)*gain(N-k);
   if abs(Y_shaped(k+1))>p_th          
      Y_shaped(k+1)=p_th;
      Y_shaped(N-k)=p_th;
   end
   k=k+1;
end;

% k_v = (0:N-1)/N;
% figure;
% plot(k_v,gain);
% title('Gain');%entire filter transfer function
% figure;%non-redundant filter transfer function
% 
% k_v = k_v*fs;
% k_v = k_v(1:N/2+1);
% plot(k_v,gain(1:N/2+1));
% title('Frequency Shaper Transfer Function');
% xlabel('Frequency (Hertz)');
% ylabel('Gain');
%xlim([0 10000]);
Y = X.*gain; % for X refer line no.27

% figure;
% subplot(3,1,1)
% plot(k_v,abs(X(1:N/2+1)));
% title('Frequency before adding gain');
% xlabel('Frequency (Hertz)');
% ylabel('Gain');
% subplot(3,1,2)
% plot(k_v,abs(Y(1:N/2+1)));
% title('Frequency after adding gain');
% xlabel('Frequency (Hertz)');
% ylabel('Gain');
% subplot(3,1,3)
% plot(k_v,abs(Y_shaped(1:N/2+1)));
% title('Frequency after adjusting');
% xlabel('Frequency (Hertz)');
% ylabel('Gain');

y = real(ifft(Y,N));
y_shaped = real (ifft(Y_shaped,N));
y = y(1:x_length);
y_shaped = y_shaped(1:x_length);
% t = (0:1/fs:(x_length-1)/fs);
% figure;
% subplot(3,1,1);
% plot(x(100:end));
% title('Input Signal');
% subplot(3,1,2);
% plot(y(100:end));
% title('Signal after addition of gain');
% subplot(3,1,3);
% plot(y_shaped(100:end));
% title('Adjusted Signal');
% 
% figure;
% subplot(3,1,1)
% plot(k_v,mag2db(abs(X(1:N/2+1))));
% title('Frequency before adding gain');
% xlabel('Frequency (Hz)');
% ylabel('Gain');
% subplot(3,1,2)
% plot(k_v,mag2db(abs(Y(1:N/2+1))));
% title('Frequency after adding gain');
% xlabel('Frequency (Hz)');
% ylabel('Gain');
% subplot(3,1,3)
% plot(k_v,mag2db(abs(Y_shaped(1:N/2+1))));
% title('Frequency after adjusting');
% xlabel('Frequency (Hz)');
% ylabel('Gain');
% 
% figure;
% plot(k_v,mag2db(abs(gain(1:N/2+1))));
% title('Frequency Shaper Transfer Function');
% xlabel('Frequency (Hz)');
% ylabel('Gain(dB)');
end