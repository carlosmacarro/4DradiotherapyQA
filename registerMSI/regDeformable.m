function [T, M2T] = regDeformable(M1, M2)
    clear param
    param.lambda = .01;       % Regularization parameter
    param.step = 5;           % Optimization step size
    param.showFigure = true;  % Show the images during registration
    
    T = registerMSI(M1, M2, param);
    M2T = interpT(T, M2);
end