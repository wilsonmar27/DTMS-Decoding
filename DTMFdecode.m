function [key,fs] = DTMFdecode(filename)

[x,fs] = audioread(filename);

[key,fs] = DTMFdecodeSignal(x,fs);

return