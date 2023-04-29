% Part IV: Decoding DTMF sequences in open environments
 
keys = '0123456789*#';
fs = 8000;
keypresses = randi([5 20]); 
signals = zeros([50 (20*250/1000 + 200*keypresses)*fs]);


% a. generate 50 random phone sequences
samples = 0;
for i = 1:50

    idx = 1; 
    for j = 1:keypresses
         % select random key and duration
        k = keys(randi(12));   
        d = randi([20, 250]);
    
        % generate keypress with default parameters
        signals(i, idx:idx+(d/1000*fs)-1) = DTMFencode(k, d); 
    
        % increase index by pause and duration of keypress
        pause_duration = (0.2*fs);
        idx = idx + pause_duration + (d/1000*fs);
    
    end
    samples = max([samples, idx-1]);
end

secs = samples/fs;
time = linspace(0, secs, samples);

% reshape to rid space at the end of each signal
signals = signals(:, 1:samples);


% b. normalize each audio signal
for i = 1:50
    signals(i) = signals(i)/(max([max(signals(i)), abs(min(signals(i)))]));
end


% c. read and normalize babble audio (noise)
[distortion,fs] = audioread('./babble.wav');
distortion = distortion/(max([max(distortion), abs(min(distortion))]));
% extend noise audio to match the length of the signal
distortion = distortion(mod(0:numel(signals(1,:))-1,numel(distortion))+1); 

% plot to see 
subplot(2,1,1);
plot(time, signals(1, :));
subplot(2,1,2);
plot(time, distortion);