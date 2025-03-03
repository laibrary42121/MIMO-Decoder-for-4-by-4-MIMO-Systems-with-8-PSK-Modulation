clear; close all;
PSK_8 = exp(1j * 2 * pi * (1/8) * (0 : 7));

total_bits = 24;
frac_bits = 16;
int_bits = 8;

[rows, cols] = size(PSK_8);
real_bin = cell(rows, cols); % 用來存實部的固定小數點二進位
imag_bin = cell(rows, cols); % 用來存虛部的固定小數點二進位

% 將實部與虛部分別取出並處理
real_part = real(PSK_8);
imag_part = imag(PSK_8);

for r = 1 : rows
    for c = 1 : cols

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
        real_bin{r, c} = dec2bin(scaled_real, total_bits);


        imag_val = imag_part(r, c);
        scaled_imag = round(imag_val * 2^frac_bits); % 乘以 2^7 並四捨五入

        if scaled_imag < -2^(total_bits-1) || scaled_imag > 2^(total_bits-1)-1
            error('Imaginary part out of representable range!');
        end
        % 如果是負數，轉成二補數格式
        if scaled_imag < 0
            scaled_imag = scaled_imag + 2^total_bits;
        end

        imag_bin{r, c} = dec2bin(scaled_imag, total_bits);
    end
end

% 顯示結果
disp('8PSK (Real parts):');
for k = 1 : 8
    disp(real_bin{1, k});
end

disp('8PSK (Imaginary parts):');
for k = 1 : 8
    disp(imag_bin{1, k});
end