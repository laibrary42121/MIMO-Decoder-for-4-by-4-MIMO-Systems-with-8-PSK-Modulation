function [x_ML, x_ML_code] = ML(H, x, v)
    
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
    Gamma_x = zeros(8^4, 1);
    X_candidates = zeros(8^4, 4);
    X_code = zeros(4, 3, 8^4);
    idx = 1;
    for p = 1 : 8
        for m = 1 : 8
            for k = 1 : 8
                for l = 1 : 8
                    x_vec = [PSK_8(p); PSK_8(m); PSK_8(k); PSK_8(l)];
                    diff = y - H * x_vec;
                    Gamma_x(idx) = norm(diff)^2;
                    X_candidates(idx, :) = x_vec.';
                    X_code(:, :, idx) = [PSK_code(p, :); PSK_code(m, :); PSK_code(k, :); PSK_code(l, :)];
                    idx = idx + 1;
                end
            end
        end
    end


    [Gamma_min, min_idx] = min(Gamma_x);
    x_ML = X_candidates(min_idx, :).';
    x_ML_code = X_code(:, :, min_idx);

end