cd 'E:\Repository\arbitrage'
clear;close all
addpath gen_function usual_function gen_function\CTA1
% ��ú�ƽ�̿
% Ʒ��
fut_variety = {'J','JM'};
% spread = data1.close * rate - data2.close����һ�ж��ǻ������˳��

% ���Բ���
paraM.win = 20; % win��Ӱ���С����Ϊֻ������һ����20��ʼ��������21��22һֱ�ۻ����ڹ����Ĳ��ǹ̶�����
paraM.win2 = 10;
paraM.rate = 1/1.35;
% ���ײ���
Cost.fix = 0; %�̶��ɱ�
Cost.float = 2; %����
tradeP = 'open'; %���׼۸�
capital = 10000000; %��ʼ���
priceType = 'close';
signalID = '101';
% �������
stDate = 0;
edDate = 20180731;
load Z:\baseData\Tdays\future\Tdays_dly.mat
totaldate = Tdays(Tdays(:,1)>=stDate & Tdays(:,1)<=edDate,1);
sigDPath = '\\Cj-lmxue-dt\�ڻ�����2.0\pairData';

% TradePara��������ز�ƽ̨
TradePara.futDataPath = '\\Cj-lmxue-dt\�ڻ�����2.0\dlyData\������Լ'; %�ڻ�������Լ����·��
TradePara.futUnitPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\minTickInfo.mat'; %�ڻ���С�䶯��λ
TradePara.futMultiPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\PunitInfo'; %�ڻ���Լ����
TradePara.futLiquidPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\liquidityInfo'; %�ڻ�Ʒ�����������ݣ�����ɸѡ����ԾƷ�֣��޳�����ԾƷ��
TradePara.futSectorPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData\SectorInfo.mat'; %�ڻ����������ݣ�����ȷ����������Ӧ��Ʒ��
TradePara.futMainContPath = '\\Cj-lmxue-dt\�ڻ�����2.0\��Ʒ�ڻ�������Լ����'; %������Լ����
% TradePara.usualPath = '..\data\usualData';%����ͨ������ �����ַ�����
TradePara.usualPath = '\\Cj-lmxue-dt\�ڻ�����2.0\usualData';
TradePara.fixC = 0.0000; %�̶��ɱ�
TradePara.slip = 2; %���� �������2��ʾ2���㣿һ��۸�������ǧ��2����Ӱ��󣿲�������۸�䶯���ܾ�ʮ������
TradePara.PType = 'open'; %���׼۸�һ����open�����̼ۣ�����avg(�վ��ۣ�

% getdata
% ��һ����Լ��������Լ��ʱ����һ���͸��Ż���֮ǰд�İ汾�и����⻹û�ģ�����t1 - t2 <=2��Ϊ��ͬ��ʱ�ڵĺ�Լ��û���ǿ�������
% �Ժ��ȡ������Լ�Ե�����ֱ�Ӵ���ѩ���pair_data����ȥ������

% ��������
load \\Cj-lmxue-dt\�ڻ�����2.0\usualData\minTickInfo.mat %Ʒ����С�䶯��λ
trade_unit = minTickInfo;
load(['\\Cj-lmxue-dt\�ڻ�����2.0\usualData\PunitInfo\',num2str(totaldate(end)),'.mat']) %��Լ����
cont_multi = infoData; %%%%%%%%%%%% ����ֻȡ����ûӰ�죬��ΪJ��JM�м�û�б仯����������ط��Ժ�Ҫ��%%%%%%%%%%%%%%%%%%%%%%%%%

proAsset = capital;
pFut1 = fut_variety{1,1};
pFut2 = fut_variety{1,2};
dataPath = [sigDPath,'\',pFut1,'_',pFut2];
% ��Լ����
contM1 = cont_multi{ismember(cont_multi(:,1),pFut1),2};
contM2 = cont_multi{ismember(cont_multi(:,1),pFut2),2};
% ����
pName = fieldnames(paraM);
for p = 1:length(pName)
    str = ['para.',pName{p},'=paraM.',pName{p},';'];
    eval(str)
end

% ���뻻��������
load(['\\Cj-lmxue-dt\�ڻ�����2.0\code2.0\data20_pair_data\chgInfo\',pFut1,'_',pFut2,'.mat'])
chgInfo = chgInfo(chgInfo.date>stDate & chgInfo.date<=edDate,:);


% �����ź�-����Լѭ��
% ÿ�κ�Լ��Ϊ������Լ��ʱ����Ϊһ���źŲ������䣬�Դ��ų���Щ�ź�һ��ȥ��Ҫ���µ����
res = totaldate(totaldate >= chgInfo.date(1));
res = res(1 : (end - 1));%82�в�֪ΪɶҪ��1����������Ҳ��1����Ȼ���һ���ǿ�ֵ
res = array2table([res, NaN(size(res, 1), 5)], 'VariableNames', {'Date', 'PosLabel', 'Hands1', 'Hands2', 'Cont1', 'Cont2'});
res.Cont1 = num2cell(res.Cont1);
res.Cont2 = num2cell(res.Cont2);

for c = 1:height(chgInfo)
    disp(c)
    startDateC = chgInfo.date(c); %�ú�Լ��ʼ��Ϊ����������
    if c~=height(chgInfo)
        c_edD = totaldate(find(totaldate==chgInfo.date(c+1),1)-1); %�ú�Լ��Ϊ�����Ľ�������
    else %���һ��
        c_edD = totaldate(find(totaldate==edDate)-1); % ΪʲôҪ��һ��
    end
    cont1 = regexp(chgInfo{c,2}{1},'\w*(?=\.)','match');
    cont2 = regexp(chgInfo{c,3}{1},'\w*(?=\.)','match');
    % ��������
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

% ��������ȡtargetPortfolio������������ز�ƽ̨
targetPortfolio = num2cell(NaN(size(res, 1), 2));   %�����ڴ�
for iDate = 1:size(res, 1)
    hands = {char(regexp(char(res(iDate, :).Cont1), '\w*(?=\.)', 'match')), res(iDate, :).Hands1;...
        char(regexp(char(res(iDate, :).Cont2), '\w*(?=\.)', 'match')), res(iDate, :).Hands2};
    targetPortfolio{iDate, 1} = hands;
    targetPortfolio{iDate, 2} = res.Date(iDate);
end

% getholdinghands���ֲ��漰�����գ���Ϊ��ÿ��ѭ���ģ���������û�к�Լ����
% ���Ǻ�Լ������Ҫ��������ز�ƽ̨���ݲ���adjFactor

[BacktestResult,err] = CTABacktest_GeneralPlatform_3(targetPortfolio,TradePara);

figure
% ��ֵ����
plot((capital + BacktestResult.nv(:, 2)) ./ capital)

BacktestAnalysis = CTAAnalysis_GeneralPlatform_2(BacktestResult);






















