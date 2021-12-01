% This is the single-resolution-level subroutine of the registerMSI
% function, which aligns images using the mid-space-independent (MSI)
% deformable registration. Consider using registerMSI for registration.
% 
% [T, cf, LS] = registerMSI_singleLevel(f, g, param, T)
% 
% f:           First (reference) input image.
% g:           Second (resampled) input image.
% param:       A structure containing the registration parameters. (See the
%              help of registerMSI.)
% T (input):   Initial value for the transformation (optional).
% 
% T (output):  The computed transformation, deforming g to f.
% cf:          Contains the evolution of the cost function terms. (Refer to
%              the code for details.)
% LS:          Stores the number of line searches at each iteration.
% 
% Reference for MSI registration:
% 
% I. Aganj, J. E. Iglesias, M. Reuter, M. R. Sabuncu, and B. Fischl,
% "Mid-space-independent deformable image registration," NeuroImage, vol.
% 152, pp. 158-170, 2017. http://doi.org/10.1016/j.neuroimage.2017.02.055
% 
% See also: registerMSI, interpT, showRegResults2D

% Code by Iman Aganj.

function [T, cf, LS] = registerMSI_singleLevel(f, g, param, T)

[Method, MethodReg, step, lambda, maxIter, logBarrier, showFigure, showLS] = deal(param.Method, param.MethodReg, param.step, param.lambda, param.maxIter, param.logBarrier, param.showFigure, param.showLS);
D = ndims(f);
if D==2
    nPastMinLS = 4;
elseif D==3
    nPastMinLS = 2;
else
    error('Invalid dimension!')
end
nRegularizationStep = 10;
minDetJ = .001;

N = size(f);

Id = f;
IdM = zeros([N 2 2], 'like', Id);
if D==2
    [Id(:,:,1), Id(:,:,2)] = ndgrid(1:N(1), 1:N(2));
    IdM(:,:,1,1) = 1; IdM(:,:,2,2) = 1;
else
    [Id(:,:,:,1), Id(:,:,:,2), Id(:,:,:,3)] = ndgrid(1:N(1), 1:N(2), 1:N(3));
    IdM(:,:,:,1,1) = 1; IdM(:,:,:,2,2) = 1; IdM(:,:,:,3,3) = 1;
end
cf = zeros(6, maxIter, 'like', Id);
LS = zeros(1, maxIter, 'like', Id);
if ~exist('T', 'var') || isempty(T)
    T = Id;
end
if Method>0
    fp = gradientD(f);
end
for i = 1:maxIter
    gI = interpT(T, g);
    SD = (f - gI).^2;
    [~, detJ] = jacobianD(T); detJ = max(detJ, minDetJ);
    cf(1:3,i) = [sum(SD(:)); detJ(:)'*SD(:); 2*sum(SD(:).*detJ(:)./(1+detJ(:)))];
    [J, detJ, ~, fiJ] = jacobianD(T, 2); detJ = max(detJ, minDetJ);
    devJ = J - IdM;
    fiJ = froSqD(fiJ-IdM, D);
    cf(4:6,i) = [devJ(:)'*devJ(:); fiJ(:)'*detJ(:); sum(sum(sum(detJ.*traceD(multD(transD(devJ,D), multD(inverseD(multD(detJ,IdM,D)+multD(J,transD(J,D),D)), devJ,D),D)))))];
    switch Method
        case 0
            dTerm = cf(1,i);
        case 1
            dTerm = .5*(cf(1,i)+cf(2,i));
        case 2
            dTerm = cf(3,i);
    end
    switch MethodReg
        case 0
            rTerm = cf(4,i);
        case 1
            rTerm = .5*(cf(4,i)+cf(5,i));
        case 2
            rTerm = cf(6,i);
    end
    fprintf(['#' num2str(i) ': CF = ' num2str(dTerm) ' + ' num2str(lambda) '*' num2str(rTerm) ' = ' num2str(dTerm+lambda*rTerm) ', '])
    
    % Data gradient
    gIp = gradientD(gI);
    switch Method
        case 0
            dGrdnt = 2*multD(-(f - gI), gIp, D);
        case 1
            dGrdnt = multD(-(f - gI), multD(detJ, fp, D) + gIp, D);
        case 2
            dGrdnt = 4*multD(-(f - gI).*detJ./((1+detJ).^2), fp + multD(detJ, gIp, D), D); %+ 2*multD(SD, gradientD((detJ0./(1+detJ0)).^2,[],true), D);
        otherwise
            error('Method should be 0, 1, or 2!')
    end
    k = 1;
    expS = Id - step*dGrdnt;
    cf_M = inf;
    while true
        T_LS = combTrans(T, expS, Id);
        % Regularization gradient
        for j=1:nRegularizationStep
            switch MethodReg
                case 0
                    rGrdnt = -2*laplacianTransD(T_LS);
                case 1
                    [J, detJ, C, iJ] = jacobianD(T_LS, 1); detJ = max(detJ, minDetJ);
                    colJ = repmat({':'}, 1, D+2);
                    for d=1:D
                        IndJ = [colJ d];
                        auxV = IdM - iJ(IndJ{:});
                        auxV2(IndJ{:}) = multD(2*multD(transD(iJ(IndJ{:}),D),auxV,D),C(IndJ{:}),D) + multD(froSqD(auxV,D),C(IndJ{:}),D) + 2*J(IndJ{:});
                    end
                    rGrdnt = -.5*divergeD(auxV2,1);
                case 2
                    [J, detJ, C] = jacobianD(T_LS, 1); detJ = max(detJ, minDetJ);
                    colD = repmat({':'}, 1, D);
                    colJ = repmat({':'}, 1, D+2);
                    for d=1:D
                        IndD = [colD d];
                        IndJ = [colJ d];
                        P = multD(inverseD(multD(J(IndJ{:}),transD(J(IndJ{:}),D),D)+multD(detJ(IndD{:}),IdM,D)), (J(IndJ{:})-IdM), D);
                        auxV = multD(transD(P,D),J(IndJ{:}),D);
                        auxV2(IndJ{:}) = multD(froSqD(auxV,D), C(IndJ{:}), D) + 2*multD(detJ(IndD{:}),multD(P,IdM-auxV,D),D);
                    end
                    rGrdnt = -divergeD(auxV2,1);
            end
            if logBarrier>0
                if MethodReg==0
                    [~, detJ] = jacobianD(T_LS, 1); detJ = max(detJ, minDetJ);
                end
                auxV = log(detJ);
                rGrdnt = rGrdnt + logBarrier * multD(cofactorD(jacobianD(T_LS)),gradientD(-(2*auxV.*(1+1./detJ) + auxV.^2), [], 1),D);
            end
            T_LS = T_LS - ((2^(k-1))*step*lambda/nRegularizationStep) * rGrdnt;
        end
        gI = interpT(T_LS, g);
        [~, detJ] = jacobianD(T_LS);
        detJ = max(detJ, minDetJ);
        SD = (f - gI).^2;
        switch Method
            case 0
                dTerm = sum(SD(:));
            case 1
                dTerm = .5*(SD(:)'*(1+detJ(:)));
            case 2
                dTerm = 2*sum(SD(:).*detJ(:)./(1+detJ(:)));
        end
        if MethodReg==1
            [J, detJ, ~, fiJ] = jacobianD(T_LS, 2);
        else
            [J, detJ] = jacobianD(T_LS, 2);
        end
        detJ = max(detJ, minDetJ);
        devJ = J - IdM;
        switch MethodReg
            case 0
                rTerm = devJ(:)'*devJ(:);
            case 1
                fiJ = froSqD(fiJ-IdM,D);
                rTerm = .5*(devJ(:)'*devJ(:) + fiJ(:)'*detJ(:));
            case 2
                rTerm = sum(sum(sum(detJ.*traceD(multD(transD(devJ,D), multD(inverseD(multD(detJ,IdM,D)+multD(J,transD(J,D),D)), devJ, D),D)))));
        end
        if logBarrier>0
            rTerm = rTerm + logBarrier*((log(detJ(:)).^2)'*(1+detJ(:)));
        end
        cf_LS = dTerm + lambda * rTerm;
        if showLS
            disp(['k = ' num2str(k) ', CF = ' num2str(dTerm) ' + ' num2str(lambda) '*' num2str(rTerm) ' = ' num2str(cf_LS)])
        end
        if k==1 || cf_LS <= cf_M
            cf_M = cf_LS;
            T_M = T_LS;
            LS(i) = k;
            kPastMinLS = 0;
        else
            kPastMinLS = kPastMinLS + 1;
        end
        if kPastMinLS < nPastMinLS
            k = k + 1;
            expS = combTrans(expS, expS, Id);
        else
            break
        end
    end
    T = T_M;
    if D==2 && showFigure
        showRegResults2D(gather(f),gather(g),gather(T))
        drawnow
    end
    disp(['LS = ' num2str(LS(i))])
    if any(isnan(T(:)))
        error('Deformation field contains NaN values.')
    end
end
