% Privacy amplification 
% Because multiple photons can be sent in a pulse from Alice to Bob, Eve
% may receive bits of the sequence by measuring stray photons. Alice and
% Bob use a public scheme to encrypt their sequences, so that any
% discrepancy in Eve's sequence will yield an encrypted key that is
% completely different from Alice's and Bob's. 
%
% Each sequence is multiplied by a publicly available matrix M
% (entries uniformly drawn from {0, 1}) of dimensions KxN, where N is the
% sequence length and K=P(n<=1)*N, where P(n<=1) is the probability that a
% pulse has less than 1 photons. 
%
% Inputs: alice - Alice's sequence
%         bob - Bob's sequence 
%
% Outputs: alice - Alice's sequence after the protocol is performed
%          bob - Bob's sequence after the protocol is performed
%          similarity - difference between Alice and Bob's sequences

function [alice, bob, similarity] = priv_amp(alice, bob)
    fprintf("Privacy amplification ...\n");
    %find P(n>1) = 1 - (1+nbar)*exp(-nbar)
    % experimental parameters
    b = 0.002275; %background 
    n0 = 3.941; %
    phi1 = -6.167; 
    phi2 = 6.05;
    x = 53.4801; 
    nbar = n0*cos(x*pi/180 - phi1)^2*cos(x*pi/180-phi2)^2+b; %expected number of photons

    p = (1+nbar)*exp(-1*nbar); %P(n<=1)
    M = round(length(alice)*p);
    alice_new = zeros(M, 1);
    bob_new = zeros(M, 1);
    
    %matrix multiplication done by generating HashMat row-by-row
    for i=1:M
        HashMat = round(rand(1, length(alice)));
        alice_new(i) = mod(HashMat*alice', 2);
        bob_new(i) = mod(HashMat*bob', 2);
    end
    
    %print similarity between the two
    alice = alice_new;
    bob = bob_new;
    similarity = (length(alice) - sum(xor(alice, bob)))/length(alice);
    fprintf("After privacy amplification, the key length is %d.\n", length(alice));
    fprintf("Similarity between Alice's and Bob's keys: %0.2f\n", similarity);
end