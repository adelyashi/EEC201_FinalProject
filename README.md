# Final Project Report
EEC 201: Digital Signal Processing\
Professor Zhi Ding\
Adelya Shimabukuro, Mandy Chokry\
15 March 2025

## Introduction
The goal of this final project is to use digital signal processing tools such as Mel-frequency cepstrum coefficients and vector quantization to develop a speaker recognition system and then train that speaker recognition system on several data sets of speech samples. This was accomplished by creating MATLAB functions and code for each aspect of the speaker recognition algorithm, which will all be broken down individually in their respective sections in this report. 

## Approaches

### Data used

There are 3 sets of audio samples available for training and testing. The following section will use the original training data provided, which comprises 11 audio recordings of the word "zero," in depicting the results of each step of the process.

### Plotting audio samples and truncating to remove silence

The file `imptruncplot.m` imports each speech sample from a given folder (in this case, the original training data of samples of "zero") into a cell array `audioData`. If the sample is stereo, it is converted to mono by taking the average of both stereo samples. To ensure that silence can be truncated consistently, DC offset subtraction was added to this portion of the code. To crop the silence out of each sample, we chose to use the short-term energy (STE) of each sample to define a threshold energy of $0.01 \times \text{STE}_{max}$ as shown below, where $k_i$ is the $i$ th sample in frame $k$ :

```math
$$E_{threshold} = 0.01 \times \text{STE}_{\text{max}} = 0.01 \times \max_{k}\left( \sum_{j = 1}^{\text{len\_frame}}k_j^2 \right)$$
```

After truncating, each signal was normalized to a maximum amplitude of 1 and plotted in the time domain. The results of this are shown below.
[insert time-domain plots of signals here]

### Periodograms

To visualize the estimated spectral density of each signal and find where the most energy lies, we used the Short-Time Fourier Transform to plot periodograms for each signal using varying window lengths. The results are shown below using window lengths of $N = 128, 256,$ and $512$, respectively.\
% insert periodograms for each N value and comment on effect of each window length

### Signal preprocessing: calculating MFCCs

Our approach in calculating the Mel-frequency cepstrum coefficients of each signal comprises 8 main sections: pre-emphasis, framing, windowing, FFT, filter banks, MFCC calculation, liftering, and mean normalization. We based parts of this approach on Haytham Fayek's[^1] 2016 article on filter banks and MFCCs.

#### Pre-emphasis filter
A first-order pre-emphasis filter is applied to the signal to emphasize higher frequencies, which typically have smaller amplitudes. The equation for this is as shown below:
$$y[n] = x[n] - 0.97x[n-1]$$

#### Framing and windowing
In framing each signal, we decided to use a typical frame length of 25 ms and a frame stride (overlap) of 10 ms, resulting in a frame step of 15 ms. 

#### 512-point DFT and power spectrum

#### Filter banks

#### Using DCT to calculate MFCCs

#### MFCC cleanup: liftering and normalization
After the MFCCs have been calculated, we filtered them in the cepstrum domain to emphasize the middle coefficients and reduce processing time because these higher coefficients do not significantly affect human perception of sound. Lastly, to best visualize the MFCCs, we applied mean normalization.
\par The results of the code \texttt{melfb\_own.m} are shown below.
% embed image here


## Feature Matching using LBG-VQ Algorithm

# Test Results and Discussion

# Conclusion


[^1]: Haytham Fayek, ["Speech Processing for Machine Learning: Filter banks, Mel-Frequency Cepstral Coefficients (MFCCs) and What's In-Between"](https://haythamfayek.com/2016/04/21/speech-processing-for-machine-learning.html#fn:1)
