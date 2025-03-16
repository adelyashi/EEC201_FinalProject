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

After truncating, each signal was normalized to a maximum amplitude of 1 and plotted in the time domain. The results of this are shown below.\
![timedomsigs](https://github.com/user-attachments/assets/535f100d-ee1b-47d7-90b1-f6c47abcc010)

### Periodograms

To visualize the estimated spectral density of each signal and find where the most energy lies, we used the Short-Time Fourier Transform to plot periodograms for each signal using varying window lengths. The results are shown below using window lengths of $N = 128, 256,$ and $512$, respectively.\
![periodogram128](https://github.com/user-attachments/assets/f1f3374b-e30f-4b29-8049-8657c13d7666)
![periodogram256](https://github.com/user-attachments/assets/5f0bdfbc-6648-4c8f-a02d-cf4b7d78eea1)
![periodogram512](https://github.com/user-attachments/assets/ab4f040a-b12b-453c-9f80-13b1d2c006be)
While the general shape of the periodograms remains relatively consistent for each signal, the measured intensity of each frequency appears to lessen as window length increases. We chose to use a windowing length of 256 for the remainder of the project as a compromise between time and frequency precision.

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
Once the MFCCs have been acquired, we can now use them to find the codebook for each unique voice using the Linde-Buzo-Gray algorithm[^2] to implement vector quantization to find the centroids of each MFCC array, as seen in the function `vq_lgb.m`. To find the optimal centroids for each MFCC array, we begin with a single centroid that is the average of every coefficient, then split it into two points that are an infinitesimally small distance apart. Then, using `disteu.m`, a provided function that calculates the Euclidean distance between two input vectors, we assign each coefficient to its nearest centroid. Once all coefficients have been assigned a nearest centroid, new centroid values are calculated by taking the mean of all coefficients assigned to a particular previous centroid. This process continues until the average distortion, or distance between a coefficient and its nearest centroid, meets a certain threshold.

# Test Results and Discussion


Results 1 : Had 1/8 correct. Soln: Removing the Liftering portion form melfb_own 
Results 2 : Had 7/8 correct. Soln: Increasing number of centroids from 16 to 64.
Final Results: Had 8/8 correct.

# Conclusion


[^1]: Haytham Fayek, ["Speech Processing for Machine Learning: Filter banks, Mel-Frequency Cepstral Coefficients (MFCCs) and What's In-Between"](https://haythamfayek.com/2016/04/21/speech-processing-for-machine-learning.html#fn:1)
[^2]: Buzo et al., [citation]
