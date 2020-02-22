% Error reconciliation protocol 
% This protocol is based on the binary search method with random shuffling,
% which is described in J. Martinez-Mateo, C. Pacher, M. Peev, A. Ciurana, 
% and V. Martin, Quantum Info. Comput. 15, 453 (2015).

% The protocol (communicated over a classical channel) compares the parity 
% of blocks of length P ("P-blocks") in Alice and Bob's sequences. In the
% pseudo-code below, the number of iterations of the protocol is "iter".
%
% 0. Initialize iter, P
% 1. For i in (1:iter)
%   a. Find num, the number of P-blocks
%   b. For j in (1:num)
%      Conduct parity check on Alice and Bob's respective blocks. 
%      If they match, remove the same bit from each block. Else, conduct a
%      binary search to find an erroneous bit and remove it. For each
%      iteration of the binary search, remove one bit as well. 
%   c. Generate a random shuffling order, which is used to shuffle Alice
%      and Bob's sequences. 
%   d. Double P
%
% Inputs: P - length of block 
%         alice - Alice's sequence
%         bob - Bob's sequence 
%         iterations - number of iterations 
%
% Outputs: alice - Alice's sequence after the protocol is performed
%          bob - Bob's sequence after the protocol is performed
%          errors_remain - number of remaining errors 
%          perc_lost - fraction of qubits that were removed 
%          asymmetry - fraction of 1s in Alice's sequence 

function [alice, bob, errors_remain, perc_lost, asymmetry] = err_corr(P, alice, bob, iterations)
fprintf("Running reconciliation protocol ...\n");
N0 = numel(alice);
N = N0;
iter_alice = [ ];
iter_bob = [ ];


for iter = 1: iterations
    
    % force a "P-even" number of bits
    N = N - mod(N,P);
    alice = alice(1:N);
    bob = bob(1:N);
    for i = 1:N/P
        % determine parity for corresponding P-blocks
        pbob = mod(sum(bob(P*(i-1)+1:P*i)),2);
        palice = mod(sum(alice(P*(i-1)+1:P*i)),2);
        if (pbob == palice)
            iter_alice = [iter_alice alice(P*(i-1)+1:P*i-1)];
            iter_bob = [iter_bob bob(P*(i-1)+1:P*i-1)];
        else
            ct = 0; % counter
            len = P; 
            alice_temp = alice(P*(i - 1) + 1: P*i); % isolate the P-blocks
            bob_temp = bob(P*(i - 1) + 1:P*i); 
            while(len >= 2)
                % perform binary search
                len = len/2.; 
                if(mod(sum(alice_temp(1:len)), 2) == mod(sum(bob_temp(1:len)), 2))
                    iter_alice = [iter_alice alice_temp(1:len - 1)]; 
                    iter_bob = [iter_bob bob_temp(1:len - 1)]; 
                    alice_temp = alice_temp(len + 1:2*len);
                    bob_temp = bob_temp(len + 1:2*len);
                else
                    iter_alice = [iter_alice alice_temp(len + 1:2*len)];
                    iter_bob = [iter_bob bob_temp(len + 1:2*len)]; 
                    alice_temp = alice_temp(1:len); 
                    bob_temp = bob_temp(1:len); 
                end
            end
        end    
    end
    % display bits removed and errors remaining
    bits_removed = N - numel(iter_alice);
    errors_remain = numel(find(xor(iter_alice, iter_bob)==1));
    fprintf("Iteration %d\nNumber of bits removed: %d\nNumber of errors remaining: %d\n", iter, bits_removed, errors_remain);
    
    % randomly shuffle sequences according to the same ordering
    N = numel(iter_alice);
    shuffle = randperm(length(iter_alice));
    alice = iter_alice(shuffle);
    bob = iter_bob(shuffle); 
    iter_alice = [ ];
    iter_bob = [ ];
    P = 2*P; % double block length for each iteration
    
    perc_lost = 100 - N/N0*100; % percentage of original sequence lost to err correction
    fprintf("Percentage of original sequence lost: %.2f\n", perc_lost); 
end
final_length = N;
fprintf("After reconciliation, the sequence length is %d.\n", final_length);
asymmetry = sum(alice)/N;
end

