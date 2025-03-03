clear; close all;
%H = (1 / sqrt(2)) * randn(4, 4) + 1j * (1/sqrt(2)) * randn(4, 4);

v = zeros(4, 1);
%v = sqrt(N0 / 2) * (randn(3, 1) + 1j * randn(3, 1))
PSK_8 = exp(1j * 2 * pi * (1/8) * (0 : 7));
PSK_code = [ ...
    [1, 1, 1];
    [1, 1, 0];
    [0, 1, 0];
    [0, 1, 1];
    [0, 0, 1];
    [0, 0, 0];
    [1, 0, 0];
    [1, 0, 1]
];


SNR = linspace(0, 30, 61);
BER = zeros(500, 61);
BER_display = zeros(1, 61);
for p = 1 : 500
    H = (1 / sqrt(2)) * randn(4, 4) + 1j * (1/sqrt(2)) * randn(4, 4);
    for SNR_idx = 1 : 61
        error = 0; 
        E_av = 1;
        N0 = E_av / 10 ^ (SNR(SNR_idx) / 10);

        for n = 1 : 10000
            
            idx = randi([1, 8], 4, 1);
            x = [PSK_8(idx(1)); PSK_8(idx(2)); PSK_8(idx(3)); PSK_8(idx(4));];
            x_code = [PSK_code(idx(1), :); PSK_code(idx(2), :); PSK_code(idx(3), :); PSK_code(idx(4), :)];
            v = sqrt(N0 / 2) * (randn(4, 1) + 1j * randn(4, 1));
            y = H * x + v;

            [x_4B, x_4B_code] = Four_best(H, x, v);
            for k = 1 : 4
                for m = 1 : 3
                    if x_4B_code(k, m) ~= x_code(k, m)
                        error = error + 1;
                    end
                end
            end


        end
        BER(p, SNR_idx) = error / (12 * 10000);

    end
    BER_display = BER_display + BER(p, :);
end
BER_display = BER_display / 500;

BER_dB = 10 * log(BER);


figure;
idx_4B = linspace(0, 30, 61);
semilogy(idx_4B, BER, 'o-');
xlabel('SNR');
xlim([0, 30]);
ylabel('BER (dB)');
ylim([1e-5, 0.5]);

%% ML search



[Q, R] = qr(H);

SNR = linspace(0, 30, 61);
BER = zeros(500, 61);
BER_display = zeros(1, 61);
for p = 1 : 500
    H = (1 / sqrt(2)) * randn(4, 4) + 1j * (1/sqrt(2)) * randn(4, 4);
    for SNR_idx = 1 : 61
        error = 0; 
        E_av = 1;
        N0 = E_av / 10 ^ (SNR(SNR_idx) / 10);

        for n = 1 : 10000
            
            idx = randi([1, 8], 4, 1);
            x = [PSK_8(idx(1)); PSK_8(idx(2)); PSK_8(idx(3)); PSK_8(idx(4));];
            x_code = [PSK_code(idx(1), :); PSK_code(idx(2), :); PSK_code(idx(3), :); PSK_code(idx(4), :)];
            v = sqrt(N0 / 2) * (randn(4, 1) + 1j * randn(4, 1));
            y = H * x + v;

            [x_ML, x_ML_code] = ML(H, x, v);
            for k = 1 : 4
                for m = 1 : 3
                    if x_ML_code(k, m) ~= x_code(k, m)
                        error = error + 1;
                    end
                end
            end


        end
        BER(p, SNR_idx) = error / (12 * 5000);

    end
    BER_display = BER_display + BER(p, :);
end
BER_display = BER_display / 500;

BER_dB = 10 * log(BER);

idx_ML = linspace(0, 30, 61);
semilogy(idx_ML, BER, 'o-');
xlabel('SNR');
xlim([0, 30]);
ylabel('BER (dB)');
ylim([1e-5, 0.5]);

legend('4-best', 'ML');




