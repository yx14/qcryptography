% Randomness extractor
% Even a slight asymmetry in the number of 0s and 1s in a sequence can
% reveal information about an encrypted message. Thus, we need a randomness
% extractor to take Alice's and Bob's sequences as input and produce their
% respective sequences with an even distribution of 0s and 1s. This process
% depends on Alice's sequence's asymmetry (the percentage of 1s in the 
% sequence -- if Alice and Bob have the same sequence post-reconciliation, 
% then their sequences will remain the same following randomness extraction. 
%
% Inputs: alice - Alice's sequence
%         bob - Bob's sequence 
%
% Outputs: alice - Alice's sequence after the randomness extractor  
%          bob - Bob's sequence after the randomness extractor
%          asymmetry - percentage of 1s in Alice's sequence 

function [alice, bob, asymmetry] = rand_extract(alice, bob)
fprintf("Randomness extraction ...\n");
q = sum(alice)/length(alice); % percentage of 1s in Alice's sequence
p = abs(q - 0.5)/q;
r_vec = rand(length(alice), 1); % public random sequence of numbers

% use q as a threshold for the entries of r_vec, and flip entries in Alice's
% and Bob's sequences accordingly
if(q > 0.5)
    for t = 1:length(alice)
        if(alice(t) && r_vec(t) < p)
            alice(t) = 0;
        end
        if(bob(t) && r_vec(t) < p)
            bob(t) = 0;
        end
    end
else
    for t = 1:length(alice)
        if(not(alice(t)) && r_vec(t) < p)
            alice(t) = 1;
        end
        if(not(bob(t)) && r_vec(t) < p)
            bob(t) = 1;
        end
    end
end
asymmetry = sum(alice)/length(alice);
fprintf("Asymmetry of Alice's sequence before extractor: %.2f\nAsymmetry of Alice's sequence after extractor: %.2f\n", ...
q, asymmetry);
end

