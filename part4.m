% Part IV: Decoding DTMF sequences in open environments
 
keys = '0123456789*#';
fs = 8000;

% placeholder where signal will be generated
signal = zeros([1 (12700/1000 + 200*50)*fs]);

% generate 50 random phone sequences
idx = 1; 
for i = 1:50
     % select random key and duration
    k = keys(randi(12));   
    d = randi([20, 250]);

    % generate keypress with default parameters
    signal(idx:idx+(d/1000*fs)-1) = DTMFencode(k, d); 

    % increase index by pause and duration of keypress
    pause_duration = (0.2*fs);
    idx = idx + pause_duration + (d/1000*fs);

end

samples = idx-1;
secs = samples/fs;
time = linspace(0, secs, samples);

% trim extra space at the end
trimmed_signal = signal(1:samples);



