[x,fs] = audioread('DTMFex/dtmf6.wav');

% Set frequences for bandpass filter
FREQ_LOW = 650;
FREQ_HI = 1550;

% rms scan window size in s
% movement of window is half the window size
WINDOW_SIZE = 0.02;
RMS_THRESH = 0.2;

% scale
x = x/(max([max(x), abs(min(x))]));

% remove offset
x = x - mean(x);
  
% samples and frequency x-axis
samples  = length(x);
step = fs/samples;
f  = (-fs/2:step:fs/2-step)';


% time info
secs = samples/fs;
ind = linspace(0, secs, samples);

% frequency response of BPF H(jw)
BPF = ((FREQ_LOW < abs(f)) & (abs(f) < FREQ_HI));

% FFT
ftx = fftshift(fft(x))/samples;

% apply filter: Y(jw) = H(jw)*X(jw)
filtered = BPF.*ftx;

% bring back to time domain
y = ifft(ifftshift(filtered));
y = real(y);

% normalize y
y = y/max([max(y), abs(min(y))]);

% detect changes in rms to trace out the wave
rmswindow = WINDOW_SIZE * fs;
rmssize = ceil(samples/rmswindow*2) + 1;
rmsvals = zeros(1,rmssize);

% trace
for i = 1:rmssize
    beg = rmswindow*(i-1)/2+1;
    fin = rmswindow*i/2;
    if fin > samples
        fin = samples;
    end
    rmsvals(i) = rms(y(beg:fin));
end

% scale rms wave
rmsvals = rmsvals/max(rmsvals);
% shift rms wave
rmsvals = [0, rmsvals(1:end-1)];
% rms wave time scale
rmstime = linspace(0,secs,rmssize);

% create beep
% beep is one wherever there is a phone beep
% allocate array
beep_inter = zeros(15, 2);
beep = zeros(1,rmssize);
curr_row = 1;

for i = 2:rmssize-1
    left_neighbor = (rmsvals(i-1) > RMS_THRESH);
    right_neighbor = (rmsvals(i+1) > RMS_THRESH);

    % beeps should be at least of length 2 
    if (rmsvals(i) > RMS_THRESH) && (left_neighbor || right_neighbor)
        beep(i) = 1;
        % where beep starts
        if beep(i-1) == 0
            beep_inter(curr_row, 1) = i-1;
        end
    else
        % where beep ends
        if beep(i-1) == 1
            beep_inter(curr_row, 2) = i;
            curr_row = curr_row + 1;
        end
    end
end

seq = "";
clear i;
for i = 1:length(beep_inter)
    if beep_inter(i,1) ~= 0
        startbeep = floor(beep_inter(i,1)*(samples/rmssize));
        endbeep = ceil(beep_inter(i,2)*(samples/rmssize));
        key = DTMFdecodeSignal(y(startbeep:endbeep), fs);
        seq = append(seq, key);
    end
end
figure('position', [120,360,1200,480]);
plot(ind,x);
hold on
plot(rmstime, rmsvals, 'LineWidth', 1, 'Color', "g");
plot(rmstime, beep, 'lineWidth', 1, 'Color', "r");
legend("Sound Wave", "Trace", "Beep");
title("Predicate Detection on dtmf6.wav");
ylabel("Value");
xlabel("Time (s)");
%saveas(gcf, "assets/BeepDetect6_freq.png");
