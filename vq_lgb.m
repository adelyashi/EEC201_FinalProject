function codebook = vq_lgb(mfcc, num_centroids, epsilon)
% Cluster finding for 1:12 dimensions of our MFCC Array
codebook = mean(mfcc, 2);

% Splitting the Centroids until we get num_centroids
while size(codebook,2) < num_centroids
    %Splitting the centroids (given equation)
    codebook = [codebook * (1 + epsilon), codebook* (1 - epsilon)];
    
    thresh=inf; Dp=inf; %settin intial threshold and distortion to infinite
    while thresh > eps
        %Nearest Neighbor Search for Current centroids (Using given disteu
        %Using given disteu function
        distances = disteu(codebook, mfcc);
        [d, which_centroid] = min(distances, [], 1);  %Assigning mfcc coeff to nearest centroids   (d - distance, which_centroid - centroid assignemnt)

        %Updating Centroids
        for c=1:size(codebook,2)
            codebook(:,c) = mean(mfcc(:,which_centroid==c),2);  % updating centroids position for each grouping of mfccs
        end

        %Computing distortion (D)
        D = mean(d); %d was taken from the min of distances 
        thresh = (Dp-D)/D; %computing euclidean distance
        Dp = D; %Re-assign D' = D 
    end
end
end

% function [codebook, which_centroid, group, group_better, centroid, current_num_centroids, centroids_updated, num_mfcc_coeff, Dn_1, dc] = vq_lgb(mfcc, num_centroids, epsilon)
% % Cluster finding for 1:12 dimensions of our MFCC Array
% codebook = mean(mfcc, 2);
% 
% % Splitting the Centroids until we get num_centroids
% while size(codebook,2) < num_centroids
%     %Splitting the centroids (given equation)
%     codebook = [codebook * (1 + epsilon), codebook* (1 - epsilon)];
% 
%     thresh=inf;
%     Dp=inf;
%     while thresh > eps
%         %Nearest Neighbor Search for Current centroids (Using given disteu
%         %Using given disteu function
%         distances = disteu(codebook, mfcc);
%         [d, which_centroid] = min(distances, [], 1);  %Assigning mfcc coeff to nearest centroids   (d - distance, which_centroid -
%         % disp(size(centroids))
%         for c=1:size(codebook,2)
%             % mean(mfcc(:,which_centroid==c),2)
%             codebook(:,c) = mean(mfcc(:,which_centroid==c),2);
%         end
% 
%         % for centroid = 1:current_num_centroids
%         %     group{centroid} = {};
%         %     for num_mfcc_coeff = 1:size(mfcc,2)
%         %         if ismember(centroid, which_centroid(:, num_mfcc_coeff))
%         %             group{centroid} = [group{centroid}, mfcc(:, num_mfcc_coeff)];
%         %             group_better{centroid} = cell2mat(group{centroid});
%         %         end
%         %     end
%         % end
% 
%         % loop/index through each column of group_better
%         % for ind = 1:current_num_centroids
%         %     if ~isempty(group_better{ind}) % open if not empty
%         %         centroids_updated(:, ind) = mean(group_better{ind}, 2); %assign centroid
%         %     end
%         % end
% 
%         D = mean(d);
%         thresh = (Dp-D)/D;
%         Dp = D;
% 
%         % for ind2 = 1:length(group_better)
%         %     n2 = size(mfcc, 2);
%         %     Dn = (1/n2)*sum(min(disteu(group_better(ind2), centroids)));
%         %     check = (Dn_1 - Dn)/(Dn);
%         % end
%     end
%     %%
%     % codebook = codebook;
%     which_centroid = 0;
%     group = 0;
%     group_better = 0;
%     centroid = 0;
%     centroids_updated = 0;
%     current_num_centroids = 0;
%     num_mfcc_coeff = 0;
%     Dn_1 = 0;
%     dc=0;
% end
% end