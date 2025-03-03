% 原始複數矩陣 H
load('H_and_R.mat');
idx = randi([1, 8], 4, 1);
y_tilde = zeros(4, 11);
x = zeros(4, 11);

PSK_8 = exp(1j * 2 * pi * (1/8) * (0 : 7));


H = [0.2765 + 0.1957i,   1.4472 + 0.0539i,  -1.5844 + 0.6201i,  -0.4077 + 0.7924i;
    -0.6606 - 0.1926i,  -0.8539 - 0.2626i, -2.0633 + 0.7958i,   0.3562 + 0.9545i;
     0.0412 + 0.4339i,  -0.3960 - 0.3542i, -0.0099 + 1.4570i,  -0.3352 - 0.4207i;
     0.4287 - 0.0089i,  -0.3623 - 0.4767i, -0.7141 - 1.0054i,  -0.4081 - 0.7408i];

[Q, R] = qr(H);

for k = 1 : 11
    N0 = 10^(-0.1 * 10);
    x(:, k) = [PSK_8(idx(1)); PSK_8(idx(2)); PSK_8(idx(3)); PSK_8(idx(4));];
    y = H * x(:, k) + sqrt(N0 / 2) * (randn(4, 1) + 1j * randn(4, 1));
    y_tilde(:, k) = Q' * y;
end


total_bits = 15;
frac_bits = 10;
int_bits = 5;

[rows, cols] = size(y_tilde);
y_r_bin = cell(rows, cols); % 用來存實部的固定小數點二進位
y_i_bin = cell(rows, cols); % 用來存虛部的固定小數點二進位

% 將實部與虛部分別取出並處理

real_part = real(y_tilde);
imag_part = imag(y_tilde);

for r = 1:rows
    for c = 1:cols

        real_val = real_part(r, c);
        scaled_real = round(real_val * 2^frac_bits); % 乘以 2^7 並四捨五入
        % 確保數值在 -1024 ~ 1023 範圍內（11 位表示的範圍）
        if scaled_real < -2^(total_bits-1) || scaled_real > 2^(total_bits-1)-1
            error('Real part out of representable range!');
        end
        % 如果是負數，轉成二補數格式
        if scaled_real < 0
            scaled_real = scaled_real + 2^total_bits;
        end
        % 轉為二進位字串
        y_r_bin{r, c} = dec2bin(scaled_real, total_bits);


        imag_val = imag_part(r, c);
        scaled_imag = round(imag_val * 2^frac_bits); % 乘以 2^7 並四捨五入

        if scaled_imag < -2^(total_bits-1) || scaled_imag > 2^(total_bits-1)-1
            error('Imaginary part out of representable range!');
        end
        % 如果是負數，轉成二補數格式
        if scaled_imag < 0
            scaled_imag = scaled_imag + 2^total_bits;
        end

        y_i_bin{r, c} = dec2bin(scaled_imag, total_bits);
    end
end

y_tilde_r_11 = cell(4, 1);
y_tilde_i_11 = cell(4, 1);
for k = 1 : 11
    fprintf('Re y_tilde %d\n', k);
    disp(y_r_bin);

    fprintf('Im y_tilde %d\n', k);
    disp(y_i_bin);
end





[rows, cols] = size(x);
x_r_bin = cell(rows, cols); % 用來存實部的固定小數點二進位
x_i_bin = cell(rows, cols); % 用來存虛部的固定小數點二進位

% 將實部與虛部分別取出並處理

real_part = real(x);
imag_part = imag(x);

for r = 1:rows
    for c = 1:cols

        real_val = real_part(r, c);
        scaled_real = round(real_val * 2^frac_bits); % 乘以 2^7 並四捨五入
        % 確保數值在 -1024 ~ 1023 範圍內（11 位表示的範圍）
        if scaled_real < -2^(total_bits-1) || scaled_real > 2^(total_bits-1)-1
            error('Real part out of representable range!');
        end
        % 如果是負數，轉成二補數格式
        if scaled_real < 0
            scaled_real = scaled_real + 2^total_bits;
        end
        % 轉為二進位字串
        x_r_bin{r, c} = dec2bin(scaled_real, total_bits);


        imag_val = imag_part(r, c);
        scaled_imag = round(imag_val * 2^frac_bits); % 乘以 2^7 並四捨五入

        if scaled_imag < -2^(total_bits-1) || scaled_imag > 2^(total_bits-1)-1
            error('Imaginary part out of representable range!');
        end
        % 如果是負數，轉成二補數格式
        if scaled_imag < 0
            scaled_imag = scaled_imag + 2^total_bits;
        end

        x_i_bin{r, c} = dec2bin(scaled_imag, total_bits);
    end
end

x_11 = cell(4, 1);
for k = 1 : 4
    temp = '';
    for m = 1 : 11
        if mod(m, 2) == 1
            temp = strcat(temp, x_r_bin{k, int32((m + 1) / 2)});
        else
            temp = strcat(temp, x_i_bin{k, int32(m / 2)});
        end
    end
    x_11{k} = temp;
end


disp('DetectedSymbol');
disp(x_11);















