function [seq,fs] = DTMFsequence(filename)

% Decodes an audio signal into the corresponding digits by using DTMF
%
% Parameters:
%   filnename: *.wav file that contains a sequence of key presses of 
%    unknown length. (must be above 3000 Hz)
%
% Output:
%   seq:    a sequence of characters corresponding the digits pressed
%   fs:     sampling rate in Hz

% Set frequences for bandpass filter
FREQ_LOW = 650;
FREQ_HI = 1550;

% rms scan window size in s
% movement of window is half the window size
WINDOW_SIZE = 0.02;
RMS_THRESH = 0.2;

% read file
[audio,fs] = audioread(filename);

% scale
audio = audio/(max([max(audio), abs(min(audio))]));

% remove offset
audio = audio - mean(audio);

% samples and frequency x-axis
samples  = length(audio);
step = fs/samples;
f_range  = (-fs/2:step:fs/2-step)';

% frequency response of BPF H(jw)
BPF = ((FREQ_LOW < abs(f_range)) & (abs(f_range) < FREQ_HI));

% FFT
ftx = fftshift(fft(audio))/samples;

% apply filter: Y(jw) = [H(jw)][X(jw)]
filtered = BPF.*ftx;

% bring back to time domain
filt_audio = ifft(ifftshift(filtered));
filt_audio = real(filt_audio);

% normalize filt_audio
filt_audio = filt_audio/max([max(filt_audio), abs(min(filt_audio))]);

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
    rmsvals(i) = rms(filt_audio(beg:fin));
end

% scale rms wave
rmsvals = rmsvals/max(rmsvals);
% shift rms wave
rmsvals = [0, rmsvals(1:end-1)];

%   create beep
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

% decode beeps and add to sequence
seq = "";
clear i;
for i = 1:length(beep_inter)
    if beep_inter(i,1) ~= 0
        startbeep = floor(beep_inter(i,1)*(samples/rmssize));
        endbeep = ceil(beep_inter(i,2)*(samples/rmssize));
        key = DTMFdecodeSignal(filt_audio(startbeep:endbeep), fs);
        seq = append(seq, key);
    end
end

return