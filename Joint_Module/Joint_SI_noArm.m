clc; clear; close all;
load('Joint_SI_CL_40s_noarm_Data.mat')
load('Joint_Init_Data.mat')

% FFT of input and ouput 
R = fft(u);
Th = fft(Theta);

index = find(F<200 * T/(2*pi)); 
% index = find(abs(R/length(R)) >= 9e-2); 
B = 0*R;                     
B(index) = Th(index)./(R(index)+ Th(index));         %System Response 
B(index) = abs(B(index));               %Magnitude of System Response
B_log = 20*log10(B);

K = mean(B_log(2:5));
K_3dB = K - 3;

Index_id1 = find(B_log(2:end) < K_3dB);
Index_id1 = Index_id1(1);
omega1 = F(Index_id1);
omega2 = 35;

figure
semilogx(F, B_log)
hold on

s = tf('s');
H = db2mag(K)/((s/omega1 + 1)*(s/omega2 + 1));
[mag, ~, wout] = bode(H, {.1,1000});
bodemag(H)

mag = reshape(mag, 1, []);
wout = reshape(wout, 1, []);
plot(wout,mag2db(mag))
xlim([1,100])
ylim([-100, 100])

max_freq = 12;
plot_data(wout, mag, F, B_log)
%% Parameter ID : K/J1 and B1/J1
K_J1 = 54.98;
B1_J1 = 36.57;

save('ID_parameters.mat', 'K_J1', 'B1_J1')

function plot_data(x1, y1, x2, y2)

figure
hold on
plot(x1, mag2db(y1))
set(gca, 'XScale', 'log')
semilogx(x2, y2, '.')
legend("Transfer Function", "Experiment Data", "Location", "southwest")
xlim([.1,100])
xlabel("Frequency (rad/s)")
ylim([-80, 40])
ylabel("Magnitude (dB)")
hold off

end
