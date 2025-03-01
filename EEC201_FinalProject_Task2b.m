% EEC 201

clear 
clc

%Task 1 
%xin:samples are stored, fs:sampling rate, nbits:# of bits each sample is encoded
[xin, fs] = audioread("s2.wav"); 
[xin1, fs] = audioread("s5.wav"); 

%play sound
if ~isempty(xin)
    sound(xin, fs);
else
    disp("Error: Audio file is empty.");
end

%plot in time domain
figure;
t = (0:length(xin1)-1) / fs;
plot(t, xin1);
xlabel('Time (s)');
ylabel('frequency (amplitude)');
title('Audio Signal in Time Domain'); 
grid on;

