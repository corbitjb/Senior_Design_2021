function multiplier = getMult(label)
% this function gets a numerical multiplier from a frequency label
if(strcmp(label,'Hz'))
    multiplier = 1;
elseif(strcmp(label,'kHz'))
    multiplier = 1e3;
elseif(strcmp(label,'MHz'))
    multiplier = 1e6;
elseif(strcmp(label,'GHz'))
    multiplier = 1e9;
end
end