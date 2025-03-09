function codebook = lbg_vq(mfcc, num_centroids, epsilon, speaker_idx)

    % initialize codebook with mean vector
    codebook = mean(mfcc, 1);  
    distortion = inf;

    % determine the number of MFCC coefficients available
    num_mfcc_coeffs = size(mfcc, 2);
    
    % dynamically select two random mfcc coefficients for visualization
    mfccx = randi([1, num_mfcc_coeffs]);  
    mfccy = randi([1, num_mfcc_coeffs]);  
    while mfccx == mfccy  % Ensure different dimensions
        mfccy = randi([1, num_mfcc_coeffs]);
    end

    % different types of points
    marker_types = {'x', 'o', 's', 'd', '^', 'v', '*', '+'};
    colors = {'b', 'r', 'g', 'm', 'c', 'k', 'y'};

    figure;
    hold on;

    while size(codebook, 1) < num_centroids
        codebook = [codebook * (1 + epsilon); codebook * (1 - epsilon)];
        
        prev_distortion = 0;
        while abs(distortion - prev_distortion) > epsilon
            distances = pdist2(codebook', data');
            [~, labels] = min(distances, [], 2);
            
            prev_distortion = distortion;
            distortion = 0;
            for i = 1:size(codebook, 1)
                cluster_vectors = mfcc(labels == i, :);
                if ~isempty(cluster_vectors)
                    codebook(i, :) = mean(cluster_vectors, 1);
                end
                distortion = distortion + sum(vecnorm(cluster_vectors - codebook(i, :), 2, 2));
            end
            distortion = distortion / size(mfcc, 1);
        end
    end

    marker = marker_types{mod(speaker_idx-1, length(marker_types))+1}; 
    color = colors{mod(speaker_idx-1, length(colors))+1};

    scatter(mfcc(:,mfccx), mfcc(:,mfccy), color, marker, 'DisplayName', ['Speaker ', num2str(speaker_idx)]);
    
    xlabel(['mfcc-', num2str(mfccx)]);
    ylabel(['mfcc-', num2str(mfccy)]);
    title('mfcc space');
    legend;
    grid on;
    hold off;
end