function plot_clustered_spike_raster(spks,C,raster_id)
% Function to plot clustered spike trains from stability analysis.
% Input: spike raster data in Humphries format        -- spks
%        community assignments from Markov stability  -- C

if nargin < 3
    raster_id = '123';
end

% only spiking neurons will be part of the community assignments, so get
% old ids first
old_ids = unique(spks(:,1));
T = [0,ceil(max(spks(:,2)))];  % trial length

% check if clustering starts with zero or one and get number of clusters.
if min(C)==0
    C= C+1;
end
num_clusters = max(C);

% group labels with old ids, and
grouping = [old_ids C];

plot_clusters(spks,grouping,num_clusters,T,raster_id);


end
