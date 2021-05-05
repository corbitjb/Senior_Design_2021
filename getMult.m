function multiplier = getMult(unit)
% this function gets a numerical multiplier from a frequency label
if(strcmp(unit,'Hz'))
    multiplier = 1;
elseif(strcmp(unit,'kHz'))
    multiplier = 1e3;
elseif(strcmp(unit,'MHz'))
    multiplier = 1e6;
elseif(strcmp(unit,'GHz'))
    multiplier = 1e9;
end
end % end of function