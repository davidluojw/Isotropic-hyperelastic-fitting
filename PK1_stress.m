function P11 = PK1_stress(params, x)
    
    % Uniaxial Tension
    % F = {};
    % for i = 1:length(x)
    %     F{i} = Tensor2_3D().gen_F(x(i), 1.0 / sqrt(x(i)), 1.0 / sqrt(x(i)));
    %     detF(i) = x(i) * 1.0 / sqrt(x(i)) * 1.0 / sqrt(x(i));  % incompressible, J= 1
    % end

    % Pure Shear
    % F = {};
    % for i = 1:length(x)
    %     F{i} = Tensor2_3D().gen_F(x(i), 1.0, 1.0 / x(i)) ;
    %     detF(i) = x(i) * 1.0 / x(i);  % incompressible, J= 1
    % end

    % Equibiaxial Tension
    F = {};
    for i = 1:length(x)
        F{i} = Tensor2_3D().gen_F(x(i), x(i), 1.0 / ( x(i) * x(i) ) );
        detF(i) = x(i) *  x(i) * 1.0 / (x(i) * x(i) );  % incompressible, J= 1
    end


    S_ich = {};
    S_ich_1 = PK2_stress_ich(params(1:3), x, F, detF);
    S_ich_2 = PK2_stress_ich(params(4:6), x, F, detF);
    for i = 1:length(x)
        S_ich_i = Tensor2_3D();
        S_ich_i.mat = S_ich_1{i}.mat + S_ich_2{i}.mat;
        S_ich{i} = S_ich_i;
    end

    Pressure = zeros(length(x), 1);  % pressurea
    P = {};  % PK1
    P11 = zeros(length(x), 1);
    for i = 1:length(x)
        FSichFT = F{i}.Ten2RdotTen2(S_ich{i}).Ten2RdotTen2(F{i}.gen_transpose());
        Pressure(i) = 1.0 / detF(i) * FSichFT.mat(3,3);

        tmpC = Tensor2_3D().gen_C(F{i});
        invC = Tensor2_3D(inv(tmpC.mat));

        SvolMat = - detF(i) * Pressure(i) * invC.mat;
        S_vol = Tensor2_3D(SvolMat);
        FSvol = F{i}.Ten2RdotTen2(S_vol);

        FSich = F{i}.Ten2RdotTen2(S_ich{i});

        P{i} = Tensor2_3D();
        P{i}.mat = FSvol.mat + FSich.mat;

        P11(i) = P{i}.mat(1,1);

    end

end
