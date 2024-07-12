clc; clear; close all;


% 读取数据
data = readtable('Treloar_UT.xlsx');
data = table2array(data);
x = data(:,2);
y = data(:,3);

lb = [0, 0, 0, 0, 0];
ub = [inf, inf, inf, inf, inf];


% 定义目标函数
% loss = @loss;
objectiveFunction = @(params) loss(params, data);

% 设置初始参数估计
initialParams = [1; 1; 1; 1; 1; 1; 1; 1];


% 调用 lsqnonlin 进行优化
options = optimoptions('lsqnonlin', ...
                       'Algorithm', 'interior-point', ...
                       'MaxIterations', 10000, ...
                       'Display', 'iter'); % 设置选项以显示迭代信息
[optimizedParams, resnorm] = lsqnonlin(objectiveFunction, initialParams, lb, ub, options);

% 输出优化结果
disp('优化后的参数:');
disp(optimizedParams);

disp('残差平方和:');
disp(resnorm);

% 绘制拟合曲线
xFit = linspace(min(x), max(x), 100); % 修正了xFit的范围
yFit = PK1_stress(optimizedParams, xFit);

figure;
plot(x, y, 'bo', 'DisplayName', 'Data');
hold on;
plot(xFit, yFit, 'r-', 'DisplayName', 'Fitted Curve');
legend show;
title('Data Fitting using lsqnonlin');
xlabel('x');
ylabel('y');


