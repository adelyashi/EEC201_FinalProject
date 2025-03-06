hamlen = 256;
hamincr = ceil(hamlen / 3);

spcgData = cell(length(audioData), 1);
perdg_dBData = cell(length(audioData), 1);

figure;
for i = 1:length(audioData)
    
    audio = audioData{i};
    [spcg, fspcg, tspcg] = stft(audio, 12500, Window=hamming(hamlen), OverlapLength=hamincr, FFTLength=hamlen);
    perdg = abs(spcg).^2 / hamlen;
    perdg_dB = 20 * log10(perdg + eps);
    
    subplot(3, 4, i)
    imagesc(tspcg, fspcg, perdg_dB);
    axis xy;
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title(['Periodogram for Signal #', num2str(i)]);
    colormap jet;
    colorbar;

end