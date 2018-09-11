function [pureEntryIdx, pureExitIdx] = puresignal(entrySignal, exitSignal)
%PURESIGNAL

% ��һ��ȱ�ݣ������󿪲ֽ���û���������һ�ο����պ���ļ��źŶ�û���ٴ����ˡ���
% ����ʽ����ƽ���źţ����һ��ƽ���ź��Ժ�Ŀ����ź�ȫ��Ϊ0��������ͬ����ûƽ�ֵ�����Ҳһ��������
% ������ô������Ϊ�㲻֪������Ҫ�����ˡ������Կ����ź�����ʱ��ֻ�ܽ�ȥ����

N = size(entrySignal, 1);

pureEntryIdx = zeros(N, 1);
pureExitIdx = zeros(N, 1);

i = 1;
% j = 0; % �б�Ҫ��
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

% ��һ��ȱ�ݣ������󿪲ֽ���û���������һ�ο����պ���ļ��źŶ�û���ٴ����ˡ���
% ���洦�����ȱ�ݣ�����pureExit����ȥ�����һ����0��ֵ��ƽ���գ���Ȼ��ȥ���idx������pureEntryIdx���ǲ���ȫΪ0�� ������ǣ��Ǿ��ǿ���δƽ��
% ����ƽ��������ȥ�ҵ�һ�������գ�֮���ÿ�������ź�ȫ����Ϊ0

lastExitIdx = find(pureExitIdx, 1, 'last');
if any(pureEntryIdx((lastExitIdx + 1) : end) ~= 0)
    % ƽ���ź��ж��ٸ����ж��ٶԿ�ƽ��
    kPair = sum(abs(pureExitIdx));
    entryIdx = find(pureEntryIdx, kPair+ 1, 'first');
    lastEntryIdx = entryIdx(end);
    pureEntryIdx((lastEntryIdx + 1) : end) = 0;
    
end

end




