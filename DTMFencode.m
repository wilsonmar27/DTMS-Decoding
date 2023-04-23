function [x, fs] = DTMFencode(key, duration, weight, fs)

% Generates the DTMF soundwave corresponding to the key pressed
%
% Parameters:
%   key:        a character corresponding to one of twelve possible keys
% 
%   duration:   [optional argument] desired duration of the signal in ms
% 
%   weight:     [optional argument] 1x2 vector with desired weight of low 
%               and high frequency component.
% 
%   fs:         [optional argument] sampling rate in Hz. Values below 
%               3000Hz will not be accepted
%
% Defaults:
%   duration = 200
%   weight = [1 1]
%   fs = 8000
%
% Output:
%   x:  output sound waveform generated by pressing the corresponding key
%   fs: sampling rate in Hz

% handle input arguments
if ~exist("duration", "var")
    duration = 200;
end

if ~exist("weight", "var")
    weight = [1 1];
end

if ~exist("fs", "var")
    fs = 8000;
end

if fs < 3000
    error("fs entered is bellow 3000Hz");
end

% posible digits matrix
digits = ['123'; '456'; '789'; '*0#'];

if ~ismember(key, digits)
    error("Invalid key entry")
end

% Create basis waves
secs = duration/1000;
samples = secs*fs;                  % Smaple amount
ind = linspace(0, secs, samples);   % Independent variable
waves = zeros(7,samples);           % allocate array

freqs = [697 770 852 941 1209 1336 1477];

% initialize the basis waves
for i = 1:7
    waves(i,:) = sin((freqs(i)*2*pi).*ind);
end

% row select
for i = 1:4
    if ismember(key, digits(i,:))
        wave1 = waves(i,:);
    end
end

% column select
for i = 1:3
    if ismember(key, digits(:,i))
        wave2 = waves(i+4,:);
    end
end

% output wave
x = weight(1).*wave1 + weight(2).*wave2;


return