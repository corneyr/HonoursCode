%%% function [dxdt] = derivative(x, window, polyorder, difforder)
% Calculates the discrete derivative using Savitzky-Golay filter
% 'window' specifies the size of the data range used for each calculation (must be an odd number)
% 'polyorder' is the order of polynomial used for the differentiation
% 'difforder' is the differentiation order (i.e. 1st diff, 2nd diff etc)

function [dxdt] = derivative(x, window, polyorder, difforder)

if analysis.iseven(window)
    error('derivative: ''window'' must be an odd number');
end

dxdt = zeros(length(x),1);
width = 0.5*(window-1);

for xi = 1:width
    coef = analysis.sgsdf(1:window, polyorder, difforder, xi, 0);    
    for ci = 1:window
        dxdt(xi) = dxdt(xi) + coef(ci)*x(ci);    
    end    
end

coef = analysis.sgsdf(-width:width, polyorder, difforder, 0, 0);    
for xi = (width+1):(length(x)-width)
    for ci = 1:length(coef)
        dxdt(xi) = dxdt(xi) + coef(ci)*x(xi-width+ci-1);
    end
end

for xi = length(x)-width+1:length(x)
    coef = analysis.sgsdf(1:window, polyorder, difforder, xi-length(x)+window, 0);    
    for ci = 1:window
        dxdt(xi) = dxdt(xi) + coef(ci)*x(ci);    
    end    
end



