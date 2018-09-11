function [res] = SSA(inputVector, win, k)
%SVDDECOMP k�����ɷֱ��, k = 1�������trend, k = 2�������noise���ڵ�һ�����ɷ��ܹ����;��󲿷ֵ�����£�

% �����ƶ����ھ���Hankel ��ΪH
H = hankel(inputVector(1:(length(inputVector) -win + 1)), inputVector((length(inputVector) - win + 1): length(inputVector)));
% construct H'H
C = H' * H;

[U, ~, ~] = svd(C); % U��������������U��V��ǰ�ȸ�vector��һ����
% �ع�����
HHat = H * U(:, k) * U(:, k)'; % �����H��U1�ϵ�ͶӰ����H*U(:,1)�Ϳ����ˣ�ΪʲôҪ�ٳ���(U:, 1)'��

% �Խ�ƽ������
% ��ʵ���ǴӾ�����ʽ��ά��������ÿ�����Խ�������һ��Ԫ�أ��������ֵ��̮����һ������
% ���Hhat>win�У����м����һЩn��Ԫ���ظ����֣����Hhat < win�У������size(Hhat, 1)��Ԫ���ظ�����
% ������ط��㾫ȷ��û�ã���Ϊ��ȥ�Ժ���recycledSSA�����õĶ�ֻ�����һ��ֵ��Ҳ����Hhat(end)���Ԫ��
res = NaN(size(HHat, 1) + size(HHat, 2) - 1, 1);
for p = 1 : (size(HHat, 1) + size(HHat, 2) - 1)
    HSum = 0;
    alpha = 0;
    for i = 1 : min(p, size(HHat, 1))
        j = p - i + 1;
        if(j <= size(HHat, 2))
            add = HHat(i, j);
            alpha = alpha + 1;
        else
            add = 0;
        end
        HSum = HSum + add;
    end
    res(p) = HSum / alpha;
end


end

