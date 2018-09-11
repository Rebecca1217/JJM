function res = getholdinghands(label, data1, data2, para, priceType, fut_variety, capital)
%���뱾�𣬼۸�1��Ʒ������1���۸�2��Ʒ������2�������ձ�ǩ�����ݺ�Լ��������𼰶�����������������Ի���������
% ratio��ʾ����Ʒ��1/Ʒ��2�Ķ�����ֵ��Ŀǰ����ֻ����������Ʒ�����
% load ��Լ����
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

% ����n��ʽ���ܽ����Լ۸�ȡ��������PP=3MA+800���ͼ���1��PP����Ӧ����MA��Ȼ���ʽ����������ʽ����n��
hands1 = 1;
str = ['hands2 = 1 .* res.', strcat(fut_variety{1}, 'Unit'), './ (para.rate .* res.', strcat(fut_variety{2}, 'Unit)'), ';'];
eval(str)
str = ['n = round(capital ./ (hands1 .* res.', strcat(fut_variety{1}, 'Unit'), ...
    '.* price1 + hands2 .* res.', strcat(fut_variety{2}, 'Unit'), '.* price2));'];
eval(str) % ����ط�ȡfloor�Ļ��������屾�𲻳���capital,round�Ļ������и��еͣ����ֶ����ԣ�Ϊ�˺���ѩ�ɶ�����round

shiftIdx = [0; diff(label)] ~= 0; 
shiftIdx = shiftIdx .* label;

hands1 = round(hands1 .* n .* shiftIdx);
hands2 = round(hands2 .* n .* shiftIdx);

hands1 = fillzero(hands1) .* abs(label);
hands2 = fillzero(hands2) .* abs(label);

hands2 = -hands2; % ��Զ���ǵڶ���Ʒ�ַ����෴

res.Hands1 = hands1;
res.Hands2 = hands2;
res = res(:, {'Date', 'PosLabel', 'Hands1', 'Hands2'});

end