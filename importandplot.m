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

    % normalize each audio to max amplitude of 1
    maxamp = max(abs(audio));
    audio = audio / maxamp;

    if (mean(audio(1:0.2 * fs)) > 0.01)
        audio = audio - mean(audio(1:0.2 * fs));
    end

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

disp('ok done')

