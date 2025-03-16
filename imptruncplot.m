% import files into cell array
folderPath = "C:\eec201\finalproject\audiofiles\train";
audioFiles = dir(fullfile(folderPath, '*.wav'));

audioData = cell(length(audioFiles), 1);

for i = 1:length(audioFiles)
    % Get full filename
    fileName = fullfile(folderPath, audioFiles(i).name);
    
    % Load the audio file
    [audio, fs] = audioread(fileName);

    % Convert stereo to mono
    if size(audio, 2) > 1
        audio = mean(audio, 2);
    end

    % remove DC offset -- mostly for samples 09, 10, 11
    audio = audio - mean(audio);
    
    N = 256; M = ceil(N / 3); % frame length and frame increment
    num_frames = ceil(abs(length(audio) - N) / M);
    totlen = (num_frames * M) + N; % zero padding to ensure all frames are same size
    padding = totlen - length(audio);
    pad_sig = [audio; zeros(padding, 1)]; 
    
    % index frames from signal
    tilea = repmat((1:M:num_frames * M)', 1, N);
    tileb = repmat(0:N-1, num_frames, 1);
    indices = tilea + tileb;
    
    frames = pad_sig(indices);
    
    stenergies = zeros(num_frames, 1);
    for j = 1:num_frames
        stenergies(j) = sum(frames(j, :) .^2);
    end
    
    threshold = 0.01 * max(stenergies);
    hasSpeech = find(stenergies > threshold);
    
    startSample = (hasSpeech(1) - 1) * M + 1;
    endSample = min((hasSpeech(end) - 1) * M + N, length(pad_sig));
    
    audio = pad_sig(startSample:endSample);

    % normalize each audio to max amplitude of 1
    maxamp = max(abs(audio));
    audio = audio / maxamp;

    % Store each audio in cell array
    audioData{i} = audio;

    % Plotting all audio files
    subplot(3, 4, i)
    t = (0:length(audio)-1) / fs;
    plot(t, audio);
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-1, 1])
    title(['Signal #', num2str(i)]); 
    grid on;
end

