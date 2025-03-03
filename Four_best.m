function [x_4B, x_4B_code] = Four_best(H, x, v)
    
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
    
    y = H * x + v;
    [Q, R] = qr(H);
    z = Q' * y;
    %z = quantized_bits(z, 5, 10);

    r = R;
    T4_nodes = zeros(8, 2);
    for k = 1 : 8
        x4 = PSK_8(k);
        T4_val = abs(z(4) - r(4, 4) * x4)^2;
        %T4_val = quantized_bits(T4_val, 5, 10);
        T4_nodes(k, :) = [T4_val, k];
    end

    T4_nodes = sortrows(T4_nodes, 1);
    T4_top4 = T4_nodes(1 : 4, :);

    T3_nodes = zeros(4 * 8, 3);
    for k = 1 : 4
        T4_val = T4_top4(k, 1);
        x4_idx = T4_top4(k, 2);
        x4 = PSK_8(x4_idx);
        for m = 1 : 8
            x3 = PSK_8(m);
            T3_val = abs(z(3) - r(3, 3) * x3 - r(3, 4) * x4)^2;
            %T3_val = quantized_bits(T3_val, 5, 10);
            total_T3_T4 = T4_val + T3_val;
            %total_T3_T4 = quantized_bits(total_T3_T4, 5, 10);
            T3_nodes(8 * (k - 1) + m, :) = [total_T3_T4, m, x4_idx];
        end
    end

    T3_nodes = sortrows(T3_nodes, 1);
    T3_top4 = T3_nodes(1 : 4, :);


    T2_nodes = zeros(4 * 8, 4);
    for k = 1 : 4
        T3_T4_val = T3_top4(k, 1);
        x3_idx = T3_top4(k, 2);
        x4_idx = T3_top4(k, 3);
        x3 = PSK_8(x3_idx);
        x4 = PSK_8(x4_idx);
        for m = 1 : 8
            x2 = PSK_8(m);
            T2_val = abs(z(2) - r(2, 2) * x2 - r(2, 3) * x3 - r(2,4) * x4)^2;
            %T2_val = quantized_bits(T2_val, 5, 10);
            total_T2_T3_T4 = T3_T4_val + T2_val; % Φ(x)
            %total_T2_T3_T4 = quantized_bits(total_T2_T3_T4, 5, 10);
            T2_nodes(8 * (k - 1) + m, :) = [total_T2_T3_T4, m, x3_idx, x4_idx];
        end
    end

    T2_nodes = sortrows(T2_nodes, 1);
    T2_top4 = T2_nodes(1 : 4, :);

    T1_nodes = zeros(4 * 8, 5);
    for k = 1 : 4
        T2_T3_T4_val = T2_top4(k, 1);
        x2_idx = T2_top4(k, 2);
        x3_idx = T2_top4(k, 3);
        x4_idx = T2_top4(k, 4);
        x2 = PSK_8(x2_idx);
        x3 = PSK_8(x3_idx);
        x4 = PSK_8(x4_idx);
        for m = 1 : 8
            x1 = PSK_8(m);
            T1_val = abs(z(1) - r(1, 1) * x1 - r(1, 2) * x2 - r(1, 3) * x3 - r(1, 4) * x4)^2;
            %T1_val = quantized_bits(T1_val, 5, 10);
            total_ED = T2_T3_T4_val + T1_val; % Φ(x)
            %total_ED = quantized_bits(total_ED, 5, 10);
            T1_nodes(8 * (k - 1) + m, :) = [total_ED, m, x2_idx, x3_idx, x4_idx];
        end
    end


    [Phi_min, min_leaf_idx] = min(T1_nodes(:, 1));
    best_x1_idx = T1_nodes(min_leaf_idx, 2);
    best_x2_idx = T1_nodes(min_leaf_idx, 3);
    best_x3_idx = T1_nodes(min_leaf_idx, 4);
    best_x4_idx = T1_nodes(min_leaf_idx, 5);

    x_4B = [PSK_8(best_x1_idx); PSK_8(best_x2_idx); PSK_8(best_x3_idx); PSK_8(best_x4_idx)];
    x_4B_code = [PSK_code(best_x1_idx, :); PSK_code(best_x2_idx, :); PSK_code(best_x3_idx, :); PSK_code(best_x4_idx, :)];


end

%{
function x_q = quantized_bits(x, intBits, fracBits)
    Q = 2^fracBits;
    xr = real(x);
    xi = imag(x);
    yr = round(xr * Q);
    yi = round(xi * Q);
    % 飽和範圍(含符號位 => intBits-1 表示正負範圍)
    maxVal = 2^(intBits - 1) - 1;
    minVal = -2^(intBits - 1);

    x_q = (yr + 1i * yi) / Q;
end
%}