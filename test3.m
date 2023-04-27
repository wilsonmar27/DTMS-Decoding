[x,fs] = audioread('DTMFex/dtmf7.wav');

% Set frequences for bandpass filter
FREQ_LOW = 650;
FREQ_HI = 1550;


% samples and frequency x-axis
samples  = length(x);
step = fs/samples;
f  = (-fs/2:step:fs/2-step)';

% time info
secs = samples/fs;
ind = linspace(0, secs, samples); 

% frequency response of BPF H(jw)
BPF = ((FREQ_LOW < abs(f)) & (abs(f) < FREQ_HI));

% remove offset
x = x - mean(x);

% FFT
ftx = fftshift(fft(x))/samples;

% apply filter: Y(jw) = H(jw)*X(jw)
filtered = BPF.*ftx;

% bring back to time domain
y = ifft(ifftshift(filtered));
y = real(y);

% normalize y
y = y/max([max(y), abs(min(y))]);

figure('position', [200,200,1080,700])
tiledlayout(2,2);

% time domain original
nexttile;
plot(ind,x);
title('Time Domain of dtmf7.wav (unfiltered)');
xlabel('Time (s)');
ylabel('Value');

% time domain filtered
nexttile;
plot(ind,y);
title('Time Domain of dtmf7.wav (filtered)');
xlabel('Time (s)');
ylabel('Value');

% freq for original 
nexttile;
plot(f,abs(ftx));
title('Frequency Domain of dtmf7.wav (unfiltered)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

% freq for filtered 
nexttile;
plot(f,abs(filtered));
title('Frequency Domain of dtmf7.wav (filtered)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

