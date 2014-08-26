function FC_MAT = createFCM(spksExc,spksInh)
% Calculate the FCM matrix for a given set of spike trains as described in
% 
% "Revealing cell assemblies at multiple levels of granularity"
% Billeh, Y. N.; Schaub, M. T.; Anastassiou, C. A.; Barahona, M. & Koch, C.
% Journal of Neuroscience Methods (2014) 
% 
% Input: spksExc -- Matrix of 2 columns with: 
%                   first column: excitatory unit index 
%                   second column: spike time
%
%        spksInh -- Matrix of 2 columns with: 
%                   first column: inhibitory unit index 
%                   second column: spike time
%                   If no inhib. units present leave empty
%
% Output: FC_MAT -- Functional connectivity matrix (NxN)
%


% time constant of exponential profile (used for coupling)
tau = 3e-3; 

% 1e-4 binless window step in seconds
step = 1e-4;   

% store ids of neurons that really fired -- corresponding to entries in
% adjacency relation
if nargin < 2
    old_ids = unique(spksExc(:,1));
    spks = [spksExc ones(length(spksExc),1)];
else
    old_ids = unique([spksExc(:,1); spksInh(:,1)]);
    spks = [spksExc ones(length(spksExc),1); spksInh -ones(length(spksInh),1)];
end
Eneuron_end = max(spksExc(:,1));
num_neurons = length(old_ids);
new_ids = sparse(old_ids,1,1:num_neurons);


% frequency of spiking for individual neurons
spike_freq = zeros(num_neurons,1);

% duration of spike trains
t_min = 0; % adjust here if signal does not start at zero
t_max = max(spks(:,2));
T = t_max - t_min;
sig_length = ceil(T/step);

% get spiking frequencies
for i = 1:num_neurons
    if i <= new_ids(Eneuron_end)
        spike_freq(i) = length(spksExc(spksExc(:,1) == old_ids(i),2))/T;
    else
        spike_freq(i) = length(spksInh(spksInh(:,1) == old_ids(i),2))/T;
    end
end


% create signals for each neuron
signals = zeros(num_neurons,sig_length);
for i=1:num_neurons
    k = old_ids(i);
    IorE = unique(spks(spks(:,1)==k,3));
    % how neuron i will influence other neurons
    signals(i,:) = create_signal(spks(spks(:,1)==k,2),step,sig_length,tau,IorE);
end

FC_MAT = zeros(num_neurons);
spike_vecs = zeros(num_neurons,sig_length);
% combine with discrete spiking events
for i=1:num_neurons
    k = old_ids(i);
    spike_times = spks(spks(:,1)==k,2);
    spike_times_vec = sparse(ceil(spike_times/step),1,1,sig_length,1);
    spike_vecs(i,:) = spike_times_vec;
    %influence on neuron i from all other neurons.
    FC_MAT(:,i) = (signals*spike_times_vec);
end

% %%%
% % alternative variant further optimized for memory!?!
% % comment out and change change FC_MAT2 to FC_MAT..
% FC_MAT2 = zeros(num_neurons);
% spike_mat = sparse(spks(:,1),floor(spks(:,2)/step),1,num_neurons,sig_length);
% for i=1:num_neurons
%     k = old_ids(i);
%     % tau is 1/10*f_spiking but bounded between tau_i_min and tau_e_max
%     tau2 = min(max(0.1/spike_freq(i),tau_i_min),tau_e_max);
%     IorE = unique(spks(spks(:,1)==k,3));
%     % how neuron i will influence other neurons
%     signal = create_signal(spks(spks(:,1)==k,2),step,sig_length,tau2,IorE);
%     % influence _from_ neuron i on all other neurons
%     FC_MAT2(i,:) = signal*spike_mat';
% end


% Threshold
FC_MAT(FC_MAT<0)= 0;
FC_MAT= FC_MAT-diag(diag(FC_MAT));

freq_normalization = (diag(spike_freq) \ ( ones(size(spike_freq))*spike_freq'))';
freq_normalization(freq_normalization>1) =1;

FC_MAT = FC_MAT.*freq_normalization;


end


function q = create_signal(start_times, dt, sig_length, tau, mode)
% create a signal from the given spike times

% time vector
t_vec = dt:dt:sig_length*dt;

q = 0;
if mode == 1
    for k = 1:length(start_times)
        qq =exp(-(t_vec-start_times(k))/tau);
        qq(qq>1)=0;
        if k < length(start_times)
            qq(t_vec>=start_times(k+1))=0;
        end
        q = q+qq;
    end
else
    for k = 1:length(start_times)
        qq =exp(-(t_vec-start_times(k))/tau);
        qq(qq>1)=0;
        qq = 1-qq;
        qq(qq>.99) = 0;% corresponds to ~4.5 tau
        if k < length(start_times)
            qq(t_vec>=start_times(k+1))=0;
        end
        q = q+qq;
    end
end

% due to rounding of spiking times, exponential may sometimes not start at 1..
if mode ==1
    q(ceil(start_times/dt))=1;
end

% shift to zero mean and make magnitude normalized
q = q-mean(q);
q = q/(max(q)*length(start_times));


end

