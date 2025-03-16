%% TESTS 1-10

% Code Description: 

clear; close all; clc;

% Define parameters
num_ceps = 12;       % Number of MFCC coefficients
cep_lifter = 22;     %  liftering parameter
nfilt = 26;          % # of mel filters
NFFT = 512;          % FFT size
num_centroids = 64;  % # of centroids
epsilon = 0.01;      % VQ distortion threshold

%% TEST 1
train_folder = 'Training_Data/';
test_folder = 'Test_Data/';
audio_files = dir(fullfile(train_folder, '*.wav'));

disp('Play each training sound file and manually recognize the speakers.');
for i = 1:length(audio_files)
    [audio, fs] = audioread(fullfile(train_folder, audio_files(i).name));
    sound(audio, fs);
    %pause(1.5);
end

disp('Now play test files randomly and try to recognize the speakers.');
test_files = dir(fullfile(test_folder, '*.wav'));
for i = randperm(length(test_files))
    [audio, fs] = audioread(fullfile(test_folder, test_files(i).name));
    sound(audio, fs);
    %pause(1.5);
end

%% TEST 2: Speech Preprocessing and STFT Analysis
filename = fullfile(train_folder, audio_files(1).name);
[audio, fs] = audioread(filename);
block_size = 256;
ms_per_block = (block_size / fs) * 1000;
disp(['Each block contains ', num2str(ms_per_block), ' ms of speech.']);

figure;
plot((1:length(audio)) / fs, audio);
xlabel('Time (s)'); ylabel('Amplitude'); title('Speech Signal');
grid on;

% Short-Time Fourier Transform
N_values = [128, 256, 512];
for N = N_values
    M = round(N / 3);
    spectrogram(audio, N, M, N, fs, 'yaxis');
    title(['STFT with Frame Size ', num2str(N)]);
    pause(2);
end

%% TEST 3: Mel Filter Bank and Spectrogram Analysis
% Compute Mel Filter Bank
mel_filters = melfb_own(filename, num_ceps, cep_lifter, nfilt, NFFT);

% plotting repsonses
figure;
plot(mel_filters');
title('Mel Filter Bank Responses');
xlabel('Frequency Bin');
ylabel('Amplitude');
grid on;

% before and after melF resp
[audio, fs] = audioread(filename);
NFFT = 512; % FFT size

% Power Spectrum
audio_spectrum = abs(fft(audio, NFFT)).^2;
freq_axis = (0:NFFT/2-1) * (fs / NFFT);

figure;
subplot(2,1,1);
plot(freq_axis, 10*log10(audio_spectrum(1:NFFT/2)));
title('Original Speech Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;

% Mel Spectrum
mel_spectrum = mel_filters * audio_spectrum(1:size(mel_filters, 2));
subplot(2,1,2);
plot(mel_spectrum);
title('Mel-Wrapped Spectrum');
xlabel('Mel Filter Index');
ylabel('Magnitude');
grid on;

%% TEST 4: MFCC Computation Verification
mfcc = melfb_own(filename, num_ceps, cep_lifter, nfilt, NFFT);
disp('MFCC comp completed.');

%% TEST 5 & 6: VQ and Clustering
mfcc = melfb_own(filename, num_ceps, cep_lifter, nfilt, NFFT);
codebook = vq_lgb(mfcc, num_centroids, epsilon);

figure;
scatter(mfcc(1, :), mfcc(2, :), 'b');
hold on;
scatter(codebook(1, :), codebook(2, :), 'r', 'filled');
title('MFCC Clustering Check');
xlabel('MFCC Dimension 1');
ylabel('MFCC Dimension 2');
legend('MFCC Vectors', 'VQ Codewords');
grid on;


%% TEST 7: Speaker Recognition System Evaluation


n_codebooks=11;
codebooks = cell(1, length(n_codebooks));
for i=1:n_codebooks
    mfcc_temp = melfb_own(sprintf('Training_Data/s%d.wav', i), num_ceps, cep_lifter, nfilt, NFFT);
    codebooks{i} = vq_lgb(mfcc_temp,num_centroids,epsilon);
end

% Perform recognition on test set
correct = 0; 
total = 8;  % We are processing files 1 to 11

for i = 1:total
    file_name = sprintf('Test_Data/s%d.wav', i); 
    
    % skip non-existent files
    if exist(file_name, 'file')
        test_mfcc = melfb_own(file_name, num_ceps, cep_lifter, nfilt, NFFT);
        min_dist = inf;
        predicted_speaker = -1;
        
        for j = 1:length(codebooks)
            dist = mean(min(disteu(codebooks{j}, test_mfcc), [], 1));
            if dist < min_dist
                min_dist = dist;
                predicted_speaker = j;
            end
        end
        
        fprintf('Test file %s is Speaker %d\n', file_name, predicted_speaker);
        % Compare with ground truth here if available
    else
        fprintf('File %s does not exist\n', file_name);
    end
end
    % disp(disteu(codebooks{j}, test_mfcc));
    % disp(codebooks{j})
    % disp(test_mfcc)
    
%% TEST 8: Notch Filter Robustness Test
% Apply a notch filter to suppress specific frequencies
notch_freqs = [60, 300, 1000]; % Example notch frequencies
for f = notch_freqs
    [b, a] = iirnotch(f / (fs / 2), 0.1);
    filtered_audio = filter(b, a, audio);
    sound(filtered_audio, fs);
    pause(2);
end

%% TEST 9: Train with EEC 2024 Students' "Zero" Samples
zero_train_folder = 'Zero-Training/';
zero_test_folder = 'Zero-Testing/';

zero_train_files = dir(fullfile(zero_train_folder, '*.wav'));
zero_test_files = dir(fullfile(zero_test_folder, '*.wav'));

zero_train_mfccs = cell(1, length(zero_train_files));
for i = 1:length(zero_train_files)
    zero_train_mfccs{i} = melfb_own(fullfile(zero_train_folder, zero_train_files(i).name), num_ceps, cep_lifter, nfilt, NFFT);
end
codebooks = [codebooks, cellfun(@(x) vq_lgb(x, num_centroids, epsilon), zero_train_mfccs, 'UniformOutput', false)];

fprintf('TEST 9: Training with additional "zero" samples complete.\n');

%% TEST 10a: Classify "Zero" vs. "Twelve"
class_folders = {'Zero-Training/', 'Twelve-Training/'};
class_labels = {'Zero', 'Twelve'};

class_codebooks = cellfun(@(folder) ...
    cellfun(@(f) vq_lgb(melfb_own(fullfile(folder, f.name), num_ceps, cep_lifter, nfilt, NFFT), num_centroids, epsilon), ...
    dir(fullfile(folder, '*.wav')), 'UniformOutput', false), class_folders, 'UniformOutput', false);

test_folders = {'Zero-Testing/', 'Twelve-Testing/'};
correct = 0; total = 0;

for c = 1:2
    test_files = dir(fullfile(test_folders{c}, '*.wav'));
    for i = 1:length(test_files)
        test_mfcc = melfb_own(fullfile(test_folders{c}, test_files(i).name), num_ceps, cep_lifter, nfilt, NFFT);
        dists = cellfun(@(cb) mean(min(disteu(cb, test_mfcc), [], 1)), class_codebooks);
        [~, pred_class] = min(dists);
        correct = correct + (pred_class == c);
        total = total + 1;
    end
end

fprintf('TEST 10a Accuracy (Zero vs. Twelve): %.2f%%\n', (correct / total) * 100);

%% TEST 10b: Classify "Five" vs. "Eleven"
class_folders = {'Five-Training/', 'Eleven-Training/'};
class_labels = {'Five', 'Eleven'};

class_codebooks = cellfun(@(folder) ...
    cellfun(@(f) vq_lgb(melfb_own(fullfile(folder, f.name), num_ceps, cep_lifter, nfilt, NFFT), num_centroids, epsilon), ...
    dir(fullfile(folder, '*.wav')), 'UniformOutput', false), class_folders, 'UniformOutput', false);

test_folders = {'Five-Testing/', 'Eleven-Testing/'};
correct = 0; total = 0;

for c = 1:2
    test_files = dir(fullfile(test_folders{c}, '*.wav'));
    for i = 1:length(test_files)
        test_mfcc = melfb_own(fullfile(test_folders{c}, test_files(i).name), num_ceps, cep_lifter, nfilt, NFFT);
        dists = cellfun(@(cb) mean(min(disteu(cb, test_mfcc), [], 1)), class_codebooks);
        [~, pred_class] = min(dists);
        correct = correct + (pred_class == c);
        total = total + 1;
    end
end

fprintf('TEST 10b Accuracy (Five vs. Eleven): %.2f%%\n', (correct / total) * 100);


disp('End of Code.');


