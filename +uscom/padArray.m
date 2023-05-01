function [padded] = padArray(data , padsize, padval)
%padArray Pad array to required length with value or truncate if too long.
%   Pad array to required length with value
padded=data;
if (length(data) > padsize)
    padded = data(1:padsize);
else
    temp = zeros(1,padsize);
    for i=1:padsize
        if (i <= length(data))
            temp(i)=data(i);
        else
            temp(i)=padval;
        end
    end
    padded=temp;
end

end

