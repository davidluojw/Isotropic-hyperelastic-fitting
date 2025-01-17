function S = PK2_stress_ich(params, x, F, detF)

    II_dot = Tensor4_3D().gen_Identity4_odot();

    C = {};          % Right Cauchy Green Tensor
    QQ_tilde = {};   % Projection Tensor
    E_tilde = {};    % Generalized strain tensor
    PP = {};         % Projection Tensor
    for i = 1:length(x)
        C{i} = Tensor2_3D().gen_C(F{i});

        invC = Tensor2_3D(inv(C{i}.mat));
        
        invCotimesC = Tensor4_3D().Ten2otimesTen2(invC, C{i});
        PP_i = Tensor4_3D();
        PP_i.mat = II_dot.mat - 1.0 / 3.0 * invCotimesC.mat;
        PP{i} = PP_i;

        [ eigvec_C, eigval_C ] = eig( C{i}.mat );

        lambda = zeros(3,1);

        lambda(1) = sqrt( eigval_C( 1, 1 ) );
        lambda(2) = sqrt( eigval_C( 2, 2 ) );
        lambda(3) = sqrt( eigval_C( 3, 3 ) ); 

        lambda_tilde = zeros(3,1);

        lambda_tilde(1) = detF(i)^(-1.0/3.0) * lambda(1);
        lambda_tilde(2) = detF(i)^(-1.0/3.0) * lambda(2);
        lambda_tilde(3) = detF(i)^(-1.0/3.0) * lambda(3);


        N = {};
        N{1} = eigvec_C( :, 1 );
        N{2} = eigvec_C( :, 2 );
        N{3} = eigvec_C( :, 3 );

        M = {};

        M{1} = Tensor2_3D().VecotimesVec(N{1}, N{1});
        M{2} = Tensor2_3D().VecotimesVec(N{2}, N{2});
        M{3} = Tensor2_3D().VecotimesVec(N{3}, N{3});

        MotimesM = Tensor4_3D();
        ModotM   = Tensor4_3D();
        E_tilde_i = Tensor2_3D();

        m = params(2); n = params(3);
         % m = 2.0; n = 2.0;

        for a = 1:3
            E_a = 1.0 / (m + n) * (power(lambda_tilde(a), m) - power(lambda_tilde(a), -n));
            E_a_prime = 1.0/(m + n) * (m * power(lambda_tilde(a), m-1) + n * power(lambda_tilde(a), -n-1));            
            E_tilde_i.mat = E_tilde_i.mat + E_a * M{a}.mat;

            d_a = 1.0 / lambda_tilde(a) * E_a_prime;

            for b = 1:3
                if (a ~= b)
                    if (lambda_tilde(a) ~= lambda_tilde(b))
                        E_b = 1.0 / (m + n) * (power(lambda_tilde(b), m) - power(lambda_tilde(b), -n));
                        vartheta_ab = 2 * ( E_a - E_b ) / (lambda_tilde(a) * lambda_tilde(a) - lambda_tilde(b) * lambda_tilde(b));
                    else
                        vartheta_ab = d_a;
                    end
                    Ma_odot_Mb = Tensor4_3D().Ten2odotTen2(N{a}, N{a}, N{b}, N{b});
                    ModotM.mat = ModotM.mat + Ma_odot_Mb.mat * vartheta_ab;
                end
            end
            Ma_otimes_Ma = Tensor4_3D().Ten2otimesTen2(M{a}, M{a});
            MotimesM.mat = MotimesM.mat + Ma_otimes_Ma.mat * d_a;
        end

        E_tilde{i} = E_tilde_i;

        QQ_tilde_i = Tensor4_3D();
        QQ_tilde_i.mat = MotimesM.mat + ModotM.mat;

        QQ_tilde{i} = QQ_tilde_i;

    end

    % EE_1 = Tensor4_3D().gen_Identity4_odot();
    % EE_2 = Tensor4_3D().gen_Identity4_otimes();
    % EE = Tensor4_3D();    
    % EE.mat = 2 * params(1) * EE_1.mat - (2.0 / 3.0 * params(1)) * EE_2.mat;

    EE = Tensor4_3D();
    EE.mat = 2 * params(1) * II_dot.mat;

   
    T_tilde = {};
    S_tilde = {};
    S = {};
    for i = 1:length(x)
        T_tilde{i} = EE.Ten4DoubleContractionTen2(E_tilde{i});  % T = EE : E
        S_tilde{i} = QQ_tilde{i}.Ten2DoubleContractionTen4(T_tilde{i});  % S = T : QQ
        S{i} = PP{i}.Ten4DoubleContractionTen2(S_tilde{i});
        S{i}.mat = detF(i)^(-1.0/3.0) * S{i}.mat;
    end




end