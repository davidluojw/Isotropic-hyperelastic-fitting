classdef Tensor4_3D
    % -----------------------
    %   A1111  A1122  A1133  A1123  A1131  A1112  A1132  A1113  A1121
    %   A2211  A2222  A2233  A2223  A2231  A2212  A2232  A2213  A2221
    %   A3311  A3322  A3333  A3323  A3331  A3312  A3332  A3313  A3321
    %   A2311  A2322  A2333  A2323  A2331  A2312  A2332  A2313  A2321
    %   A3111  A3122  A3133  A3123  A3131  A3112  A3132  A3113  A3121
    %   A1211  A1222  A1233  A1223  A1231  A1212  A1232  A1213  A1221
    %   A3211  A3222  A3233  A3223  A3231  A3212  A3232  A3213  A3221
    %   A1311  A1322  A1333  A1323  A1331  A1312  A1332  A1313  A1321
    %   A2111  A2122  A2133  A2123  A2131  A2112  A2132  A2113  A2121
    % -----------------------
    properties
        mat
    end

    methods 

        function obj = Tensor4_3D(source)
            if nargin == 0
                obj.mat = zeros(9);
            elseif nargin == 1
                obj.mat = source;
            else
                error("Too many input arguments. ");
            end
        end

        % IIodot_ijkl = I_ij odot I_kl = delta_ik delta_jl
        function out = gen_Identity4_odot(obj)
            out = Tensor4_3D(eye(9));
        end

        % IIotimes_ijkl = I_ij otimes I_kl = delta_ij delta_kl
        function out = gen_Identity4_otimes(obj)
            newMat = zeros(9);
            newMat(1:3, 1:3) = ones(3);
            out = Tensor4_3D(newMat);
        end

        % IIostar_ijkl = I_ij ostar I_kl = delta_il delta_jk
        function out = gen_Identity4_ostar(obj)
            newMat = zeros(9);
            newMat(1:3, 1:3) = eye(3);
            newMat(4:6, 7:9) = eye(3);
            newMat(7:9, 4:6) = eye(3);

            out = Tensor4_3D(newMat);
        end


        function out = Ten2toVec(obj, Ten2)

            out = zeros(9,1);
            out(1) = Ten2.mat(1,1);
            out(2) = Ten2.mat(2,2);
            out(3) = Ten2.mat(3,3);
            out(4) = Ten2.mat(2,3);
            out(5) = Ten2.mat(3,1);
            out(6) = Ten2.mat(1,2);
            out(7) = Ten2.mat(3,2);
            out(8) = Ten2.mat(1,3);
            out(9) = Ten2.mat(2,1);
        end

        function out = VectoTen2(obj, Vec)

            newMat = zeros(3);
            newMat(1,1) = Vec(1);
            newMat(2,2) = Vec(2);
            newMat(3,3) = Vec(3);
            newMat(2,3) = Vec(4);
            newMat(3,1) = Vec(5);
            newMat(1,2) = Vec(6);
            newMat(3,2) = Vec(7);
            newMat(1,3) = Vec(8);
            newMat(2,1) = Vec(9);

            out = Tensor2_3D(newMat);
        end

        % Ten2:Ten4
        % C_kl = A_ij : B_ijkl 
        function out = Ten2DoubleContractionTen4(obj, lTen2)

            % 按对应的指标顺序拉平
            oldVec = Ten2toVec(obj, lTen2);

            newVec = obj.mat' * oldVec;

            % 按对应的指标顺序还原
            out = VectoTen2(obj, newVec);


        end

        % Ten4:Ten2
        % C_ij = A_ijkl : B_kl 
        function out = Ten4DoubleContractionTen2(obj, rTen2)
            
            % 按对应的指标顺序拉平
            oldVec = Ten2toVec(obj, rTen2);

            newVec = obj.mat * oldVec;

            % 按对应的指标顺序还原
            out = VectoTen2(obj, newVec);

        end

        % Ten2 otimes Ten2
        % C_ijkl = A_ij otimes B_kl
        function out = Ten2otimesTen2(obj, lTen2, rTen2)
            lVec = Ten2toVec(obj, lTen2);
            rVec = Ten2toVec(obj, rTen2);

            newMat = lVec * rVec'; 

            out = Tensor4_3D(newMat);

        end

        % Ten2 odot Ten2 (Na, Nb)
        % Ma_ij odot Mb_kl = 0.5(Na_i otimes Nb_k otimes Na_j otimes Nb_l
        %                       +Na_i otimes Nb_k otimes Nb_l otimes Na_j)
        function out = Ten2odotTen2 (obj, Vec1, Vec2, Vec3, Vec4)
            Ten2_1 = Tensor2_3D();
            Ten2_2 = Tensor2_3D();
            Ten2_3 = Tensor2_3D();
            Ten2_4 = Tensor2_3D();

            Ten2_1 = Ten2_1.VecotimesVec(Vec1, Vec3);
            Ten2_2 = Ten2_2.VecotimesVec(Vec2, Vec4);
            Ten2_3 = Ten2_3.VecotimesVec(Vec1, Vec3);
            Ten2_4 = Ten2_4.VecotimesVec(Vec4, Vec2);

            Ten4_1 = Tensor4_3D();
            Ten4_2 = Tensor4_3D();
            out = Tensor4_3D();

            Ten4_1 = Ten2otimesTen2(obj, Ten2_1, Ten2_2);
            Ten4_2 = Ten2otimesTen2(obj, Ten2_3, Ten2_4);

            out.mat = 0.5 * (Ten4_1.mat + Ten4_2.mat);

        end

        % function out = Ten2odotTen2_2 (obj, lTen2, rTen2)
        %     out = Tensor4_3D();
        % 
        %     not_map = [1,6,8,9,2,4,5,7,3];
        % 
        %     for i = 1:3
        %         for j = 1:3
        %             for k = 1:3
        %                 for l = 1:3
        %                     I = 3*(i-1) + j;
        %                     J = 3*(k-1) + l;
        %                     I = not_map(I);
        %                     J = not_map(J);
        % 
        %                     out.mat(I,J) = lTen2.mat(i, k) * rTen2.mat(j, l);
        %                 end
        %             end
        %         end
        %     end
        % end


















        

    end


end
