function [res] = SSA(inputVector, win, k)
%SVDDECOMP k是主成分标记, k = 1输出的是trend, k = 2输出的是noise（在第一个主成分能够解释绝大部分的情况下）

% 构造移动窗口矩阵Hankel 记为H
H = hankel(inputVector(1:(length(inputVector) -win + 1)), inputVector((length(inputVector) - win + 1): length(inputVector)));
% construct H'H
C = H' * H;

[U, ~, ~] = svd(C); % U是特征向量矩阵，U和V的前秩个vector是一样的
% 重构矩阵
HHat = H * U(:, k) * U(:, k)'; % 如果是H在U1上的投影，就H*U(:,1)就可以了，为什么要再乘以(U:, 1)'？

% 对角平滑处理
% 其实就是从矩阵形式降维成向量，每个副对角线上是一个元素，对其求均值，坍缩成一个向量
% 如果Hhat>win行，则中间会有一些n个元素重复出现，如果Hhat < win行，则会有size(Hhat, 1)个元素重复出现
% 但这个地方算精确了没用，因为出去以后再recycledSSA里面用的都只有最后一个值，也就是Hhat(end)这个元素
res = NaN(size(HHat, 1) + size(HHat, 2) - 1, 1);
for p = 1 : (size(HHat, 1) + size(HHat, 2) - 1)
    HSum = 0;
    alpha = 0;
    for i = 1 : min(p, size(HHat, 1))
        j = p - i + 1;
        if(j <= size(HHat, 2))
            add = HHat(i, j);
            alpha = alpha + 1;
        else
            add = 0;
        end
        HSum = HSum + add;
    end
    res(p) = HSum / alpha;
end


end

