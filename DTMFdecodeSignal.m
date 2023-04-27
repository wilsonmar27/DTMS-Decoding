function [key,fs] = DTMFdecodeSignal(x,fs)

% Decodes an audio signal into the corresponding digit.
%
% Parameters:
%   x:  Audio signal
%   fs: sampling rate in Hz.
%
%
% Output:
%   key:    a sequence of chars corresponding to 1 of 12 possible keys.
%   fs:     sampling rate in Hz


THRESH_HEIGHT = 0.03;
THRESH_SEPERATION = 50;
samples = length(x);

% FFT
ftx = fft(x);
f2 = abs(ftx/samples);
f1 = f2(1:round(samples/2)+1);
f1(2:end-1) = 2*f1(2:end-1);
f = fs*(0:(samples/2))/samples;

%frequency range we care about 650Hz - 1550Hz
step = f(2) - f(1);
firstf = floor(650/step);
secondf = ceil(1550/step);
splitf = floor(1050/step) - firstf;

f1 = f1(firstf:secondf);
f = f(firstf:secondf);

% range 650Hz - 1050Hz
[pk1, loc1] = max(f1(1:splitf));

% range 1050Hz - 1550Hz
[pk2, loc2] = max(f1(splitf:end));
loc2 = loc2 + splitf;

% return if peak is under threshhold height
if (pk1 < THRESH_HEIGHT) || (pk2 < THRESH_HEIGHT)
    key = '';
    return
end

freqs = [697 770 852 941 1209 1336 1477];

error1 = abs(freqs - f(loc1));
error2 = abs(freqs - f(loc2));

[minerr1, err1loc] = min(error1);
[minerr2, err2loc] = min(error2);

% return if peak is over threshhold seperation
if (minerr1 > THRESH_SEPERATION) || (minerr2 > THRESH_SEPERATION)
    key = '';
    return
end

% possible digits matrix
digits = ['123'; '456'; '789'; '*0#'];

key = digits(err1loc, err2loc-4);

return