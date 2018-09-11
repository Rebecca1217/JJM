function label = sig2label(sigOpen, sigClose)
%SIG2LABEL 
N = size(sigOpen, 1);
label = zeros(N, 1);

for i = 1 : N
    if i > 1 && abs(sigClose(i)) ~= 1   
        label(i) = label(i - 1);
    end
    
    if sigOpen(i) == 1 || sigOpen(i) == -1
        label(i) = sigOpen(i);
    end
        
end

end

