[x,fs] = audioread('DTMFex/dtmf1.wav');

% rms scan window size in s
% movement of window is half the window size
WINDOW_SIZE = 0.02;

samples = length(x);
secs = samples/fs;
ind = linspace(0, secs, samples);   % Independent variable

% scale
limits = [max(x), abs(min(x))];
x = x/(max(limits));

% detect changes in rms to trace out the wave
rmswindow = WINDOW_SIZE * fs;
rmssize = ceil(samples/rmswindow*2) + 1;
rmsvals = zeros(1,rmssize);

for i = 1:rmssize
    beg = rmswindow*(i-1)/2+1;
    fin = rmswindow*i/2;
    if fin > samples
        fin = samples;
    end
    rmsvals(i) = rms(x(beg:fin));
end

% scale rms wave
rmsvals = rmsvals/max(rmsvals);
% shift rms wave
rmsvals = [0, rmsvals(1:end-1)];
% rms wave time scale
rmstime = linspace(0,secs,rmssize);

plot(ind,x);
hold on
plot(rmstime, rmsvals, 'LineWidth', 1)
legend("Sound Wave", "Trace");