function Q=Bezier(P, t)
    for k=1:length(t)
        Q(:,k)=[0 0 0]';
        for j=1:size(P,2)
            Q(:,k)=Q(:,k)+P(:,j)*Bernstein(size(P,2)-1,j-1,t(k));
        end
    end
end


function B=Bernstein(n,j,t)
        B=factorial(n)/(factorial(j)*factorial(n-j))*(t^j)*(1-t)^(n-j);
end