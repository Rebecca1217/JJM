function [pureEntryIdx, pureExitIdx] = puresignal(entrySignal, exitSignal)
%PURESIGNAL

% 有一个缺陷，如果最后开仓进了没出，那最后一次开仓日后面的假信号都没有再处理了。。
% 处理方式：看平仓信号，最后一次平仓信号以后的开仓信号全改为0，这样连同开仓没平仓的问题也一并处理了
% 不能这么处理，因为你不知道下面要换月了。。所以开仓信号来的时候只能进去。。

N = size(entrySignal, 1);

pureEntryIdx = zeros(N, 1);
pureExitIdx = zeros(N, 1);

i = 1;
% j = 0; % 有必要吗？
while i < N
    if entrySignal(i) == 1 || entrySignal(i) == -1
        pureEntryIdx(i) = entrySignal(i);
        for j = (i + 1) : N
            if exitSignal(j) == -entrySignal(i)
                pureExitIdx(j) = -entrySignal(i);
                i = j;
                j = j + 1;
                break
            else
                pureExitIdx(j) = 0;
                j = j + 1;
            end
        end
        i = i + 1;
    else
        i = i + 1;
    end
end

% 有一个缺陷，如果最后开仓进了没出，那最后一次开仓日后面的假信号都没有再处理了。。
% 下面处理这个缺陷：首先pureExit里面去找最后一个非0数值（平仓日），然后去这个idx下面找pureEntryIdx，是不是全为0， 如果不是，那就是开仓未平；
% 最后的平仓日下面去找第一个开仓日，之后的每个开仓信号全都记为0

lastExitIdx = find(pureExitIdx, 1, 'last');
if any(pureEntryIdx((lastExitIdx + 1) : end) ~= 0)
    % 平仓信号有多少个就有多少对开平仓
    kPair = sum(abs(pureExitIdx));
    entryIdx = find(pureEntryIdx, kPair+ 1, 'first');
    lastEntryIdx = entryIdx(end);
    pureEntryIdx((lastEntryIdx + 1) : end) = 0;
    
end

end




