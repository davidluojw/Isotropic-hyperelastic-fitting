function res = loss(params, data)

    % 提取 x 和 y 列数据
    x = data(:,2);
    y = data(:,3);

    
    P11 = PK1_stress(params(1:4), x);
    
    % 计算残差
    res = P11 - y;
   
end