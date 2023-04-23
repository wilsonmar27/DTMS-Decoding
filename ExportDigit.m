function [] = ExportDigit(digit)

% automizes exporting digits to .wav file and saving its plots
% function can be called in a for loop over the 12 possible digits

duration = 200;

% encode sound
[x, fs] = DTMFencode(digit, duration);

secs = duration/1000;
samples = secs*fs;                  % Smaple amount
ind = linspace(0, secs, samples);   % Independent variable

% FFT
ftx = fft(x);
f2 = abs(ftx/samples);
f1 = f2(1:samples/2+1);
f1(2:end-1) = 2*f1(2:end-1);
f = fs*(0:(samples/2))/samples;

% specify figure size
figure('position', [680,200,560,700])
tiledlayout(2,1)

% left plot (time)
nexttile
plot(ind,x)
xlabel('Time (s)')
ylabel('Value')
title(['Digit ', digit,  ' Signal in Time Domain'])

% right plot (freq)
nexttile
plot(f,abs(f1))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title(['Digit ', digit, ' Signal in Magnitude Spectrum'])

% to avoid violating proper filename convention
if digit == '*'
    digit = 'Star';
end

% save plot
filenamePlot = ['assets/digit', digit, '.png'];
saveas(gcf, filenamePlot);
close all;

% Save audio file
filenameAudio = ['digits/digit', digit, '.wav'];
% Scale audio to avoid clipping
limits = [max(x), abs(min(x))];
x = x/(max(limits));
audiowrite(filenameAudio,x,fs);

end