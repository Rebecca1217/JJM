function [pureEntryIdx, pureExitIdx] = puresignal(entrySignal, exitSignal)
%PURESIGNAL

N = size(entrySignal, 1);

pureEntryIdx = zeros(N, 1);
pureExitIdx = zeros(N, 1);

i = 1;
j = 0; % ÓÐ±ØÒªÂð£¿
while i < N
    if entrySignal(i) == 1
        pureEntryIdx(i) = 1;
        for j = (i + 1) : N
            if exitSignal(j) == -1
                pureExitIdx(j) = -1;
                i = j;
                j = j + 1;
                break
            else
                j = j + 1;
            end
        end
        i = i + 1;
    else
        i = i + 1;
    end
end

end




