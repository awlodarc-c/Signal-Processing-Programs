% Andrew Wlodarczyk
% Holtan Lab 7 -- FIR Filters
%% 7.3.1 Matlab function to display magnitude on a dB scale

h = fir1(20, 0.5, rectwin(21));
magdb(h, 'b')
title('Rectangular Window in dB')

%% 7.3.2 Investigate filter behavior

%h = fir1(N-1, wc, rectwin(N));
%h = fir1(N-1, wc, hamming(N));
%h = fir1(N-1, wc, kaiser(N, beta));

%% 7.3.3 Comparative behavior of window filters

h_N1 = fir1(20, 0.5, rectwin(21));
h_N2 = fir1(30, 0.5, rectwin(31));
h_N3 = fir1(40, 0.5, rectwin(41));


figure(1)
hold on
magdb(h_N1, 'b')
magdb(h_N2, 'r')
magdb(h_N3, 'black')
title('Nth order Rectangular Window')
hold off

h_w1 = fir1(30, 0.2, rectwin(31));
h_w2 = fir1(30, 0.4, rectwin(31));
h_w3 = fir1(30, 0.6, rectwin(31));


figure(2)
hold on
magdb(h_w1, 'b')
magdb(h_w2, 'r')
magdb(h_w3, 'black')
title('Rectangular Window over wc')
hold off

h_ham = fir1(20, 0.5, hamming(21));

figure(3)
hold on 
magdb(h_ham, 'b')
magdb(h_N1, 'r')
title('Rectangular vs Hamming Window')
hold off

h_k1 = fir1(20, 0.5, kaiser(21, 5));
h_k2 = fir1(30, 0.5, kaiser(31, 5));
h_k3 = fir1(40, 0.5, kaiser(41, 5));

figure(4)
hold on
magdb(h_k1, 'b')
magdb(h_k2, 'r')
magdb(h_k3, 'black')
title('Nth order Kaiser Window')
hold off

h_kb1 = fir1(20, 0.5, kaiser(21, 2));
h_kb2 = fir1(20, 0.5, kaiser(21, 4));
h_kb3 = fir1(20, 0.5, kaiser(21, 6));

figure(5)
hold on
magdb(h_kb1, 'b')
magdb(h_kb2, 'r')
magdb(h_kb3, 'black')
title('Kaiser Window over B')
hold off

h_lp_k = fir1(36, 0.4, 'high', kaiser(37, 5.65326));

figure(6)
magdb(h_lp_k, 'b')
title('High Pass Kaiser Window')

%% 7.3.4 Phone tones

delta = 0.01;
fc_low = 1000;
fc_high = 1150;

[x, fs] = audioread('phonetones.wav');

ws = fc_low/(fs/2);
wp = fc_high/(fs/2);
delta_w = wp-ws;

A = -20*log10(delta);

if A > 50
    beta = 0.1102*(A-8.7);
elseif A >= 21 && A < 50
    beta = 0.5842*(A-21)^0.4 + 0.07886*(A-21);
else
    beta = 0;
end

N = ceil((A-8)/(2.285*delta_w));

if mod(N, 2) == 0
    N = N+1;
end

h_low = fir1(N-1, ws, kaiser(N, beta));
h_high = fir1(N-1, wp,'high', kaiser(N, beta));

x_low = filter(h_low, 1, x);
x_high = filter(h_high, 1, x);

audiowrite('sr.wav', x_low, fs);
audiowrite('sc.wav', x_high, fs);

figure(7)
hold on;
magdb(h_low, 'b');
magdb(h_high, 'r');
title('Frequency Responses of Filters');
hold off











