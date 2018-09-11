function res = getholdinghands(label, data1, data2, para, priceType, fut_variety, capital)
%输入本金，价格1，品种名称1，价格2，品种名称2，换仓日标签，根据合约名义金额，本金及二者手数比例输出各自换仓日手数
% ratio表示的是品种1/品种2的吨数比值，目前函数只适用于两个品种情况
% load 合约乘数
unitInfo = load('E:\futureData\unitInfo.mat');
unitInfo = unitInfo.unitInfo;
unitInfo = unitInfo(unitInfo.Date >= min(data1.date) & ...
    unitInfo.Date <= max(data1.date), {'Date', fut_variety{1}, fut_variety{2}});
if size(unitInfo, 1) ~= length(data1.date)
    error('Inconsistent in the date series between price and unitInfo!')
end
str = ['price1 = data1.', priceType, ';'];
eval(str)
str = ['price2 = data2.', priceType, ';'];
eval(str)

res = [table2array(unitInfo), price1, price2, label];
res = array2table(res, 'VariableNames', {'Date', strcat(fut_variety{1}, 'Unit'), strcat(fut_variety{2}, 'Unit'), ...
    strcat(fut_variety{1}, 'Price'), strcat(fut_variety{2}, 'Price'), 'PosLabel'});

% 计算n倍式，总金额除以价格取整，比如PP=3MA+800，就计算1手PP，对应几手MA，然后资金用于这个等式够做n次
hands1 = 1;
str = ['hands2 = 1 .* res.', strcat(fut_variety{1}, 'Unit'), './ (para.rate .* res.', strcat(fut_variety{2}, 'Unit)'), ';'];
eval(str)
str = ['n = round(capital ./ (hands1 .* res.', strcat(fut_variety{1}, 'Unit'), ...
    '.* price1 + hands2 .* res.', strcat(fut_variety{2}, 'Unit'), '.* price2));'];
eval(str) % 这个地方取floor的话就是名义本金不超过capital,round的话就是有高有低，两种都可以，为了和漫雪可对照用round

shiftIdx = [0; diff(label)] ~= 0; 
shiftIdx = shiftIdx .* label;

hands1 = round(hands1 .* n .* shiftIdx);
hands2 = round(hands2 .* n .* shiftIdx);

hands1 = fillzero(hands1) .* abs(label);
hands2 = fillzero(hands2) .* abs(label);

hands2 = -hands2; % 永远都是第二个品种方向相反

res.Hands1 = hands1;
res.Hands2 = hands2;
res = res(:, {'Date', 'PosLabel', 'Hands1', 'Hands2'});

end