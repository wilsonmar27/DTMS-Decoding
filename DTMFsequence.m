function [seq,fs] = DTMFsequence(filename)

% Decodes an audio signal into the corresponding digit.
%
% Parameters:
%   filnename: *.wav file that contains a sequence of key presses of 
%    unknown length. (must be above 3000 Hz)
%
% Output:
%   seq:    a sequence of character corresponding to one of twelve possible keys
%   fs:     sampling rate in Hz


% load the audio file
[x,fs] = audioread(filename);

duration = length(x) / fs;  % in seconds

% frame sizes
frame_size = (250/1000) * fs;
frame_step = (125/1000) * fs;

% divide the signal into these frames 
num_frames = floor((length(x)-frame_size)/frame_step)+1;
frames = zeros(num_frames, frame_size);
for i = 1:num_frames
    frame_start = (i-1)*frame_step+1;
    frame_end = frame_start+frame_size-1;
    frames(i,:) = x(frame_start:frame_end);
end

seq = "";

% for each frame, detect what value it is
for i=1:num_frames
    % use decode function to find key
    key = DTMFdecode(frames[i]);
    strcat(seq, key);
end

end