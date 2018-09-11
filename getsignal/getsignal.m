function [sigOpen,sigClose,lines] = getsignal(data1, data2, para)
%GETSIGNAL 得到的sigOpen和sigClose都是经过puresignal处理过的真正开平仓信号
% data1和data2是同一个主力合约区间段的数据，时间完全一样

lines = signalprep(data1, data2, para);

% 开仓信号
movH_BF1 = [nan;lines.MovMaxNoise(1:end-1)];
movL_BF1 = [nan;lines.MovMinNoise(1:end-1)];

opIdx1 = lines.Noise >= movH_BF1 & [0; diff(lines.SpreadH)] >= 0 & lines.TrendUp == 1;
opIdx2 = lines.Noise <= movL_BF1 & [0; diff(lines.SpreadH)] <= 0 & lines.TrendDown == 1;
sigOpen = zeros(length(opIdx1), 1);
sigOpen(opIdx1) = 1;
sigOpen(opIdx2) = -1;

% 平仓信号
clsIdx1 = [0; diff(lines.Noise)] < 0 & ~lines.NoiseHighIdx;
clsIdx2 = [0; diff(lines.Noise)] > 0 & ~lines.NoiseLowIdx;
sigClose = zeros(length(clsIdx1), 1);
sigClose(clsIdx1) = -1;
sigClose(clsIdx2) = 1;

% pure signal
[sigOpen, sigClose] = puresignal(sigOpen, sigClose);

end

