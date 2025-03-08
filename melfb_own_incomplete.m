function mfcc = melfb_own(filename, num_ceps, cep_lifter, nfilt, NFFT)
    % Function to compute MFCCs from a WAV file
    % Inputs:
    %   - filename: Name of the WAV file
    %   - num_ceps: Number of MFCC coefficients to keep
    %   - cep_lifter: Cepstral liftering parameter
    %   - nfilt: Number of Mel filters
    %   - NFFT: FFT size
    % Output:
    %   - mfcc: Matrix of MFCC coefficients (frames x num_ceps)
    
    % Load audio file
    [audio, fs] = audioread(filename);  
    audio = audio / max(abs(audio));  % Normalize amplitude

    % 1 Pre-emphasis filter
    pre_emphasis = 0.97;
    emphasized_signal = [audio(1); audio(2:end) - pre_emphasis * audio(1:end-1)];

    % 2 Framing
    frame_size = 0.025;  % 25 ms
    frame_stride = 0.01; % 10 ms
    N = round(frame_size * fs); 
    M = round((frame_size - frame_stride) * fs);
    frame_step = N - M;  
    num_frames = ceil((length(emphasized_signal) - N) / frame_step) + 1;
    pad_signal_length = num_frames * frame_step + N;
    pad_signal = [emphasized_signal; zeros(pad_signal_length - length(emphasized_signal), 1)];
    indices = repmat((0:N-1)', 1, num_frames) + repmat((0:frame_step:(num_frames-1)*frame_step), N, 1);
    frames = pad_signal(indices + 1); 

    % 3️ Windowing (Hamming Window)
    hammingWindow = hamming(N);
    windowed_frames = frames .* hammingWindow;

    % 4️ FFT and Power Spectrum
    mag_frames = abs(fft(frames, NFFT));  
    mag_frames = mag_frames(1:NFFT/2+1, :);  
    pow_frames = (1.0 / NFFT) * (mag_frames .^ 2);

    % 5 MEL Filter Banks (Using Your Function `melfb_own`)
    fbank = melfb_own(nfilt, NFFT, fs); % Your custom function for filter banks
    filter_banks = fbank * pow_frames;

    % Numerical Stability
    filter_banks(filter_banks == 0) = eps;
    filter_banks = 20 * log10(filter_banks);

    % 6️ MFCC Calculation
    mfcc = dct(filter_banks, [], 2);
    mfcc = mfcc(:, 2:num_ceps + 1); % Exclude first coefficient
    mfcc = mfcc * sqrt(2 / size(filter_banks, 2)); % Normalization

    % 7️ Cepstral Liftering
    [nframes, ncoeff] = size(mfcc);
    n = (0:ncoeff-1);
    lift = 1 + (cep_lifter / 2) * sin(pi * n / cep_lifter);
    mfcc = mfcc .* lift;

    % 8️ Mean Normalization
    mean_mfcc = mean(mfcc, 1);
    mfcc = mfcc - (mean_mfcc + 1e-8);

    disp('MFCC computation complete.');
end
