function evenness = iseven(input)
%ISEVEN decides whether numberic input is even
    if mod(input,2)
        evenness = false;
    else
        evenness = true;
    end
end

