function P11 = PK1_stress(params, x)

    F = {};
    for i = 1:length(x)
        F{i} = Tensor2_3D().gen_F(x(i), 1.0 / sqrt(x(i)), 1.0 / sqrt(x(i)));
    end

    

    C = {};
    QQ = {};
    E = {};
    for i = 1:length(x)
        C{i} = Tensor2_3D().gen_C(F{i});

        [ eigvec_C, eigval_C ] = eig( C{i}.mat );

        lambda = zeros(3,1);

        lambda(1) = sqrt( eigval_C( 1, 1 ) );
        lambda(2) = sqrt( eigval_C( 2, 2 ) );
        lambda(3) = sqrt( eigval_C( 3, 3 ) ); 

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
        E_i = Tensor2_3D();

        m = params(3); n = params(4);

        for a = 1:3
            E_a = 1.0 / (m + n) * (power(lambda(a), m) - power(lambda(a), -n));
            E_a_prime = 1.0/(m + n) * (m * power(lambda(a), m-1) + n * power(lambda(a), -n-1));            
            E_i.mat = E_i.mat + E_a * M{a}.mat;

            d_a = 1.0 / lambda(a) * E_a_prime;

            for b = 1:3
                if (a ~= b)
                    if (lambda(a) ~= lambda(b))
                        E_b = 1.0 / (m + n) * (power(lambda(b), m) - power(lambda(b), -n));
                        vartheta_ab = 2 * ( E_a - E_b ) ...
                                           / (lambda(a) * lambda(a) - lambda(b) * lambda(b));
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

        E{i} = E_i;

        QQ_i = Tensor4_3D();
        QQ_i.mat = MotimesM.mat + ModotM.mat;

        QQ{i} = QQ_i;

    end

    EE_1 = Tensor4_3D().gen_Identity4_odot();
    EE_2 = Tensor4_3D().gen_Identity4_otimes();
    EE = Tensor4_3D();
    EE.mat = 2 * params(1) * EE_1.mat - (2.0 / 3.0 * params(1) + params(2) ) * EE_2.mat;
    
    T = {};
    S = {};
    P = {};
    P11 = zeros(length(x), 1);
    for i = 1:length(x)
        T{i} = EE.Ten4DoubleContractionTen2(E{i});  % T = EE : E
        S{i} = QQ{i}.Ten2DoubleContractionTen4(T{i});  % S = T : QQ
        P{i} = F{i}.Ten2RdotTen2(S{i});
        P11(i) = P{i}.mat(1,1);
        % tmp = 0;
        % for a = 1:3
        %     if (tmp < P{i}.mat(a,a))
        %         tmp = P{i}.mat(a,a);
        %     end
        % end
        % P11(i) = tmp;
    end


end