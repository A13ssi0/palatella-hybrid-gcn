function Anorm = normAdjacency(A)
degree = sum(A, 2);
degreeInvSqrt = sqrt(1./abs(degree)); % TODO remove abs()
D = diag(degreeInvSqrt);
Anorm = D * A * D;
end