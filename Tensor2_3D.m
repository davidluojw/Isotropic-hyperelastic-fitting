classdef Tensor2_3D
    % -----------------------
    %   A11  A12  A13  
    %   A21  A22  A23
    %   A31  A32  A33
    % -----------------------
    properties
        mat
    end

    methods 

        function obj = Tensor2_3D(source)
            if nargin == 0
                obj.mat = zeros(3);
            elseif nargin == 1
                obj.mat = source;
            else
                error("Too many input arguments. ");
            end
        end

        function out = gen_Identity2(obj)
            out = Tensor2_3D();
            out.mat = eye(3);
        end

        function out = gen_C(obj, F)
            out = Tensor2_3D();
            out.mat = transpose(F.mat) * F.mat;
        end

        function out = gen_F(obj, lambda1, lambda2, lambda3)
            newMat = eye(3);
            newMat(1,1) = lambda1;
            newMat(2,2) = lambda2;
            newMat(3,3) = lambda3;
            out = Tensor2_3D(newMat);
        end

        % Vec otimes Vec
        % lVec and rVec: dimension must be (3,1)
        function obj = VecotimesVec(obj, lVec, rVec)
            [lrows, ~] = size(lVec);
            [rrows, ~] = size(lVec);
            if (lrows == 1)
                error("lVec is not a column vector");
            end
            if (rrows == 1)
                error("rVec is not a column vector");
            end

            newMat = zeros(3);
            newMat = lVec * rVec';

            obj = Tensor2_3D(newMat);
        end

        function out = Ten2RdotTen2(obj, rTen2)
            out = Tensor2_3D();
            out.mat = obj.mat * rTen2.mat;
        end


    end


end
