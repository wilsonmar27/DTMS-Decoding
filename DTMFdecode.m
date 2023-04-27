function [key,fs] = DTMFdecode(filename)
% Decodes an audio signal into the corresponding digit.
%
% NOTE: This function calls the DTMFdecodeSignal which does the decoding. 
% This function is meant to fullfill function requirements sepecified by
% the project discription
%
% Parameters:
%   filnename: *.wav file that contains a sequence of key presses of 
%               unknown length. (must be above 3000 Hz)
%
% Output:
%   key:    a sequence of character corresponding to one of twelve possible keys
%   fs:     sampling rate in Hz

[x,fs] = audioread(filename);

[key,fs] = DTMFdecodeSignal(x,fs);

return