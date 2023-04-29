% Part IV: Decoding DTMF sequences in open environments
 
keys = '0123456789*#';
fs = 8000;

signals = zeros([50 (10*250/1000 + 200*20)*fs]);
sequences = cell(50, 1);

% a. generate 50 random phone sequences
samples = 0;
for i = 1:50
    keypresses = randi([5 10]); 
    sequence = "";
    idx = 1; 
    for j = 1:keypresses
         % select random key and duration
        k = keys(randi(12)); 
        sequence = append(sequence, k);
        d = randi([20, 250]);
    
        % generate keypress with default parameters
        signals(i, idx:idx+(d/1000*fs)-1) = DTMFencode(k, d, [1, 1], fs); 
    
        % increase index by pause and duration of keypress
        pause_duration = (0.1*fs);
        idx = idx + pause_duration + (d/1000*fs);
    
    end
    samples = max([samples, idx-1]);
    sequences{i} = sequence;
end

secs = samples/fs;
time = linspace(0, secs, samples);

% reshape to rid space at the end of each signal
signals = signals(:, 1:samples);

% b. normalize each audio signal
for i = 1:50
    signals(i) = signals(i)/(max([max(signals(i,:)), abs(min(signals(i,:)))]));
end


% c. read and normalize babble audio (noise)
[distortion,fs] = audioread('./babble.wav');
distortion = distortion/(max([max(distortion), abs(min(distortion))]));
% extend noise audio to match the length of the signal
distortion = distortion(mod(0:numel(signals(1,:))-1,numel(distortion))+1); 

% plot to see 
subplot(2,1,1);

% increment noise and check how many sequences are correct
accuracy = zeros([21, 2]);
accuracy(:, 1) = 1:0.1:3;

for j=1:21
    num_correct = 0;
    sequence = ""; 
    a = accuracy(j,1);
    scaled_distortion = a .* distortion';
    for i=1:50
        seq = "";
        noisy_signal = scaled_distortion + signals(i,:);

        % Save signal is temporary audio file
        x = signals(i,:);
        limits = [max(x), abs(min(x))];
        x = x/(max(limits));
        audiowrite('temp.wav',x,fs);
      
        % decode and check for accuracy
        [seq, ~] = DTMFsequence('temp.wav');
        if (seq == sequences{i})
            num_correct = num_correct + 1;
        end

        % check output
%         fprintf('For noise level %d, decoded %s when answer is %s\n', a, seq, sequences{i});
    end
    fprintf('For noise level %.1f, %d/50 decoded accurately\n', a, num_correct);
    % store average of that noise level
    accuracy(j,2) = num_correct/50;

end
disp(accuracy);