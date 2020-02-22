clear
%% Simulated quantum key distribution based on the B92 protocol (C. H. Bennett, Phys. Rev. Lett. 68, 3121 (1992))
% The purpose of this lab experiment is to understand the steps of quantum
% key distribution, which delivers a "one-time pad" (a binary sequence) 
% from the sender, Alice, to the recipient, Bob. The sequence is delivered
% by encoding 1s and 0s in the polarization of photons. 
%
% Sequence delivery was performed experimentally for the lab experiment,
% and we do a simulation of it here.
%
% each element in the sequence is encoded as a polarized photon in state |n°> 
npts = 100000; % number of points in the sequence 
sent_raw = randsample([0, 1], npts, true); % Alice's sequence, where 0 -> |45°> and 1 -> |0°>
ch1 = zeros(1, npts); % initialize channel 1 for Bob's data acquisition, corresponds to projection measurement to |90°>
ch2 = zeros(1, npts); % initialize channel 2 for Bob's data acquisition, corresponds to projection measurement to |-45°>

% measurement noise
noise = 0.005;

for i = 1:npts
    if randsample([0, 1], 1) == 0 % Bob does a projection measurement to |90°> with probability 1/2, which detects the 0 state 1/2 of the time 
        if sent_raw(i) == 0 
            ch1(i) = randsample([0, 1], 1, true, [1/2, 1/2]); % 1 if the 0 state detected, 0 otherwise
            ch2(i) = randsample([0, 1], 1, true, [1 - noise, noise]); 
        else % no detection 
            ch1(i) = randsample([0, 1], 1, true, [1 - noise, noise]);
            ch2(i) = randsample([0, 1], 1, true, [1 - noise, noise]);
        end
    else % Bob does a projection measurement to |-45°>, which detects the 1 state 1/2 of the time
        if sent_raw(i) == 0 % no detection
            ch1(i) = randsample([0, 1], 1, true, [1 - noise, noise]);
            ch2(i) = randsample([0, 1], 1, true, [1 - noise, noise]);
        else
            ch2(i) = randsample([0, 1], 1, true, [1/2, 1/2]); % 1 if the 1 state detected, 0 otherwise
            ch1(i) = randsample([0, 1], 1, true, [1 - noise, noise]); 
        end
    end 
end

% from channels 1 and 2, contruct the sequence that Bob detects
nkeep = find(xor(ch1, ch2) == 1); % Bob's detections (with errors) 
alice_seq0 = sent_raw(nkeep); % Alice keeps her subsequence based on Bob's detections
bob_seq0 = (ch2(nkeep) - ch1(nkeep) + 1)/2; % Bob's sequence
%% Reconciliation and key generation
% Due to measurement noise, Alice and Bob then apply an error 
% reconciliation protocol to their sequences. Afterward, to correct for a
% potential asymmetry in the ratio of 1s:0s in their keys, they apply a
% randomness extractor. Finally, should some fraction of their sequences be
% known to an eavesdropper, Alice and Bob then apply a privacy 
% amplification procedure to their sequences and obtain their key for
% future communication. 

fprintf('Length of Bob''s received sequence: %d\nNumber of bit-flip errors: %d\n', length(bob_seq0), numel(find(xor(alice_seq0,bob_seq0) == 1))); 

% Error correction procedure
iter = 5;
[alice_seq1, bob_seq1, errors_remain, perc_lost, asymmetry] = err_corr(32, alice_seq0, bob_seq0, iter);

% Randomness extraction
[alice_seq2, bob_seq2, asymmetrynew] = rand_extract(alice_seq1, bob_seq1);

% Privacy amplification yields Alice's and Bob's final keys 
[alice_key, bob_key, similarity] = priv_amp(alice_seq2, bob_seq2);
final_asymmetry = sum(alice_key)/length(alice_key);

% Write data to file 
%file_name = strcat(date, '_data.dat');
%dlmwrite(file_name, [30 npts length(bob_seq0) bitfliperrors iter errors_remain perc_lost asymmetry asymmetrynew similarity], '-append');