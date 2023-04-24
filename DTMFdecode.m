function [key,fs] = DTMFdecode(filename)

[x,fs] = audioread(filename);
samples = length(x);

% FFT
ftx = fft(x);
f2 = abs(ftx/samples);
f1 = f2(1:samples/2+1);
f1(2:end-1) = 2*f1(2:end-1);
f = fs*(0:(samples/2))/samples;

%frequency range we care about 600Hz - 2000Hz
step = f(2) - f(1);
firstf = floor(600/step);
secondf = ceil(2000/step);

f1 = f1(firstf:secondf);
f = f(firstf:secondf);

[pks, locs] = findpeaks(f1,f,'MinPeakDistance',50,'MinPeakHeight',0.1);

while length(pks) > 2
    [minpk, minloc] = min(pks);
    pks.remove(minpk);
    locs.remove(minloc);
end

% return if no peaks found
if (length(locs) < 2)
    key = '';
    return
end

freqs = [697 770 852 941 1209 1336 1477];

error1 = abs(freqs - locs(1));
error2 = abs(freqs - locs(2));

[minerr1, err1loc] = min(error1);
[minerr2, err2loc] = min(error2);

if (minerr1 > 50) || (minerr2 > 50)
    key = '';
    return
end

%possible digits matrix
digits = ['123'; '456'; '789'; '*0#'];

key = digits(err1loc, err2loc-4);

return