To run, do

run 'qkd_script.m' in MATLAB. 

The script simulates quantum key distribution, in which Alice 
sends a sequence of bits to Bob. Due to noise, the sequence isn't exactly the
same. Both Alice and Bob then coordinate over classical channels to process
their respective sequences: error correction to mitigate the effect of noise, 
randomness extraction to balance the percentage of 0s and 1s, and privacy
amplification via hashing to minimize eavesdroppers from reconstructing a 
similar, but erroneous, sequence.

Outputs include:
- the number of remaining errors and the percentage of lost bits 
  from error correction
- asymmetry of Alice and Bob's sequences after randomness extraction
- the final key length after privacy amplification 
- the final similarity between Alice and Bob's sequences
  