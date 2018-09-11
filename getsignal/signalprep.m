function [lines] = signalprep(data1, data2, para)
%SIGNALPREP inputtable should contain:data1, data2, para
% output includes:信号需要的各变量

pName = fieldnames(para);
for p = 1:length(pName)
    str = [pName{p},'=para.',pName{p},';'];
    eval(str)
end

lines = table(data1.date, data1.close, data2.close); % data1是J，data2是JM
lines.Properties.VariableNames = {'Date', 'Data1Close', 'Data2Close'};
lines.Spread = para.rate * lines.Data1Close - lines.Data2Close;

lines.Trend = recycledSSA(lines.Spread, para.win, 1);
lines.Noise = recycledSSA(lines.Spread, para.win, 2);


%% signal variable preparation:
% noise的movmax(win2)
movmaxNoise = movmax(lines.Noise, [win2 - 1, 0]);
movmaxNoise(win:win+win2-2) = cummax(lines.Noise(1:win2-1)); % 这一步的目的是:把前win2个空出来，不然movmax遇到NaN会自动补齐
% 直接赋成NaN效果一样
lines.MovMaxNoise = movmaxNoise;

movminNoise = movmin(lines.Noise, [win2 - 1, 0]);
movminNoise(win : (win + win2 - 2)) = cummin(lines.Noise(1 : (win2 - 1)));
lines.MovMinNoise = movminNoise;

% Spread 的极大值向上跳升/极小值向下跳跌
dif_S = [0;diff(lines.Spread)];
dif_S_BF1 = [0;dif_S(1:end-1)];
lines.SpreadHighIdx = dif_S<0 & dif_S_BF1>0;
lines.SpreadLowIdx = dif_S>0 & dif_S_BF1<0;

spreadH = nan(length(lines.Spread),1);
spreadH(lines.SpreadHighIdx) = lines.Spread(find(lines.SpreadHighIdx)-1);% 极大/小值对应的价差 用于与前一个极大/小值对比
% 因为在极大值的收盘当天不知道它是极大值，需要第二天收盘才知道前一天是极大值
lines.SpreadH = fillmissing(spreadH,'previous');

spreadL = nan(length(lines.Spread),1);
spreadL(lines.SpreadLowIdx) = lines.Spread(find(lines.SpreadLowIdx)-1); 
lines.SpreadL = fillmissing(spreadL,'previous');


% lines.SpreadHUp = [0; diff(lines.SpreadH)] >= 0;
% lines.SpreadLDown = [0; diff(lines.SpreadL)] <= 0;

% Trend处于上升通道
lines.TrendUp = [0; diff(lines.Trend)] > 0;
lines.TrendDown = [0; diff(lines.Trend)] < 0;

% Noise 上升/下降通道
% 局部高低点noise
dif_N = [0; diff(lines.Noise)];
dif_N_BF1 = [0; dif_N(1 : end - 1)];
lines.NoiseHighIdx = dif_N < 0 & dif_N_BF1 > 0; % 开始下落的点
lines.NoiseLowIdx = dif_N > 0 & dif_N_BF1 < 0; % 开始回升的点, lines.pivotL - 1就是极小值index
end

