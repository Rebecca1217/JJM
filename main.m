cd 'E:\Repository\arbitrage'
clear;close all
addpath gen_function usual_function gen_function\CTA1
% 焦煤制焦炭
% 品种
fut_variety = {'J','JM'};
% spread = data1.close * rate - data2.close后面一切都是基于这个顺序

% 策略参数
paraM.win = 20; % win的影响很小，因为只决定了一个从20开始，后面是21，22一直累积窗口滚动的不是固定窗口
paraM.win2 = 10;
paraM.rate = 1/1.35;
% 交易参数
Cost.fix = 0; %固定成本
Cost.float = 2; %滑点
tradeP = 'open'; %交易价格
capital = 10000000; %初始金额
priceType = 'close';
signalID = '101';
% 数据相关
stDate = 0;
edDate = 20180731;
load Z:\baseData\Tdays\future\Tdays_dly.mat
totaldate = Tdays(Tdays(:,1)>=stDate & Tdays(:,1)<=edDate,1);
sigDPath = '\\Cj-lmxue-dt\期货数据2.0\pairData';

% TradePara用于输入回测平台
TradePara.futDataPath = '\\Cj-lmxue-dt\期货数据2.0\dlyData\主力合约'; %期货主力合约数据路径
TradePara.futUnitPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\minTickInfo.mat'; %期货最小变动单位
TradePara.futMultiPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\PunitInfo'; %期货合约乘数
TradePara.futLiquidPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\liquidityInfo'; %期货品种流动性数据，用来筛选出活跃品种，剔除不活跃品种
TradePara.futSectorPath = '\\Cj-lmxue-dt\期货数据2.0\usualData\SectorInfo.mat'; %期货样本池数据，用来确定样本集对应的品种
TradePara.futMainContPath = '\\Cj-lmxue-dt\期货数据2.0\商品期货主力合约代码'; %主力合约代码
% TradePara.usualPath = '..\data\usualData';%基础通用数据 这个地址是哪里？
TradePara.usualPath = '\\Cj-lmxue-dt\期货数据2.0\usualData';
TradePara.fixC = 0.0000; %固定成本
TradePara.slip = 2; %滑点 滑点等于2表示2个点？一般价格都是三四千，2个点影响大？不过当天价格变动可能就十几个点
TradePara.PType = 'open'; %交易价格，一般用open（开盘价）或者avg(日均价）

% getdata
% 第一个合约换主力合约的时候另一个就跟着换，之前写的版本有个问题还没改，就是t1 - t2 <=2认为是同个时期的合约，没考虑跨年的情况
% 以后获取套利合约对的数据直接从漫雪存的pair_data里面去读即可

% 导入数据
load \\Cj-lmxue-dt\期货数据2.0\usualData\minTickInfo.mat %品种最小变动价位
trade_unit = minTickInfo;
load(['\\Cj-lmxue-dt\期货数据2.0\usualData\PunitInfo\',num2str(totaldate(end)),'.mat']) %合约乘数
cont_multi = infoData; %%%%%%%%%%%% 这里只取最新没影响，因为J和JM中间没有变化过，但这个地方以后要改%%%%%%%%%%%%%%%%%%%%%%%%%

proAsset = capital;
pFut1 = fut_variety{1,1};
pFut2 = fut_variety{1,2};
dataPath = [sigDPath,'\',pFut1,'_',pFut2];
% 合约乘数
contM1 = cont_multi{ismember(cont_multi(:,1),pFut1),2};
contM2 = cont_multi{ismember(cont_multi(:,1),pFut2),2};
% 参数
pName = fieldnames(paraM);
for p = 1:length(pName)
    str = ['para.',pName{p},'=paraM.',pName{p},';'];
    eval(str)
end

% 导入换月日数据
load(['\\Cj-lmxue-dt\期货数据2.0\code2.0\data20_pair_data\chgInfo\',pFut1,'_',pFut2,'.mat'])
chgInfo = chgInfo(chgInfo.date>stDate & chgInfo.date<=edDate,:);


% 生成信号-按合约循环
% 每段合约作为主力合约的时间作为一个信号产生区间，以此排除那些信号一进去就要换月的情况
res = totaldate(totaldate >= chgInfo.date(1));
res = res(1 : (end - 1));%82行不知为啥要减1，所以这里也减1，不然最后一行是空值
res = array2table([res, NaN(size(res, 1), 5)], 'VariableNames', {'Date', 'PosLabel', 'Hands1', 'Hands2', 'Cont1', 'Cont2'});
res.Cont1 = num2cell(res.Cont1);
res.Cont2 = num2cell(res.Cont2);

for c = 1:height(chgInfo)
    disp(c)
    startDateC = chgInfo.date(c); %该合约开始作为主力的日期
    if c~=height(chgInfo)
        c_edD = totaldate(find(totaldate==chgInfo.date(c+1),1)-1); %该合约作为主力的结束日期
    else %最后一段
        c_edD = totaldate(find(totaldate==edDate)-1); % 为什么要减一？
    end
    cont1 = regexp(chgInfo{c,2}{1},'\w*(?=\.)','match');
    cont2 = regexp(chgInfo{c,3}{1},'\w*(?=\.)','match');
    % 导入数据
    data1 = getData([dataPath,'\',pFut1,'\',cont1{1},'.mat'],edDate);
    data2 = getData([dataPath,'\',pFut2,'\',cont2{1},'.mat'],edDate);
    data1 = data1(data1.date >= startDateC & data1.date <= c_edD, :);
    data2 = data2(data2.date >= startDateC & data2.date <= c_edD, :);
    [sigOpen,sigClose,lines] = getsignal(data1, data2, para);
    label = sig2label(sigOpen, sigClose);
    
    hands = getholdinghands(label, data1, data2, para, priceType, fut_variety, capital);
    hands.Cont1 = data1.fut;
    hands.Cont2 = data2.fut;
    
    fromIdx = find(res.Date == startDateC);
    endIdx = find(res.Date == c_edD);
    res((fromIdx : endIdx), :) = hands;
end

% 接下来获取targetPortfolio数据用于输入回测平台
targetPortfolio = num2cell(NaN(size(res, 1), 2));   %分配内存
for iDate = 1:size(res, 1)
    hands = {char(regexp(char(res(iDate, :).Cont1), '\w*(?=\.)', 'match')), res(iDate, :).Hands1;...
        char(regexp(char(res(iDate, :).Cont2), '\w*(?=\.)', 'match')), res(iDate, :).Hands2};
    targetPortfolio{iDate, 1} = hands;
    targetPortfolio{iDate, 2} = res.Date(iDate);
end

% getholdinghands部分不涉及换月日，因为是每段循环的，本部分内没有合约换月
% 但是合约换月日要用于输入回测平台数据部分adjFactor

[BacktestResult,err] = CTABacktest_GeneralPlatform_3(targetPortfolio,TradePara);

figure
% 净值曲线
plot((capital + BacktestResult.nv(:, 2)) ./ capital)

BacktestAnalysis = CTAAnalysis_GeneralPlatform_2(BacktestResult);






















