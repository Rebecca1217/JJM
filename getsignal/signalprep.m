function [lines] = signalprep(data1, data2, para)
%SIGNALPREP inputtable should contain:data1, data2, para
% output includes:�ź���Ҫ�ĸ�����

pName = fieldnames(para);
for p = 1:length(pName)
    str = [pName{p},'=para.',pName{p},';'];
    eval(str)
end

lines = table(data1.date, data1.close, data2.close); % data1��J��data2��JM
lines.Properties.VariableNames = {'Date', 'Data1Close', 'Data2Close'};
lines.Spread = para.rate * lines.Data1Close - lines.Data2Close;

lines.Trend = recycledSSA(lines.Spread, para.win, 1);
lines.Noise = recycledSSA(lines.Spread, para.win, 2);


%% signal variable preparation:
% noise��movmax(win2)
movmaxNoise = movmax(lines.Noise, [win2 - 1, 0]);
movmaxNoise(win:win+win2-2) = cummax(lines.Noise(1:win2-1)); % ��һ����Ŀ����:��ǰwin2���ճ�������Ȼmovmax����NaN���Զ�����
% ֱ�Ӹ���NaNЧ��һ��
lines.MovMaxNoise = movmaxNoise;

movminNoise = movmin(lines.Noise, [win2 - 1, 0]);
movminNoise(win : (win + win2 - 2)) = cummin(lines.Noise(1 : (win2 - 1)));
lines.MovMinNoise = movminNoise;

% Spread �ļ���ֵ��������/��Сֵ��������
dif_S = [0;diff(lines.Spread)];
dif_S_BF1 = [0;dif_S(1:end-1)];
lines.SpreadHighIdx = dif_S<0 & dif_S_BF1>0;
lines.SpreadLowIdx = dif_S>0 & dif_S_BF1<0;

spreadH = nan(length(lines.Spread),1);
spreadH(lines.SpreadHighIdx) = lines.Spread(find(lines.SpreadHighIdx)-1);% ����/Сֵ��Ӧ�ļ۲� ������ǰһ������/Сֵ�Ա�
% ��Ϊ�ڼ���ֵ�����̵��첻֪�����Ǽ���ֵ����Ҫ�ڶ������̲�֪��ǰһ���Ǽ���ֵ
lines.SpreadH = fillmissing(spreadH,'previous');

spreadL = nan(length(lines.Spread),1);
spreadL(lines.SpreadLowIdx) = lines.Spread(find(lines.SpreadLowIdx)-1); 
lines.SpreadL = fillmissing(spreadL,'previous');


% lines.SpreadHUp = [0; diff(lines.SpreadH)] >= 0;
% lines.SpreadLDown = [0; diff(lines.SpreadL)] <= 0;

% Trend��������ͨ��
lines.TrendUp = [0; diff(lines.Trend)] > 0;
lines.TrendDown = [0; diff(lines.Trend)] < 0;

% Noise ����/�½�ͨ��
% �ֲ��ߵ͵�noise
dif_N = [0; diff(lines.Noise)];
dif_N_BF1 = [0; dif_N(1 : end - 1)];
lines.NoiseHighIdx = dif_N < 0 & dif_N_BF1 > 0; % ��ʼ����ĵ�
lines.NoiseLowIdx = dif_N > 0 & dif_N_BF1 < 0; % ��ʼ�����ĵ�, lines.pivotL - 1���Ǽ�Сֵindex
end

