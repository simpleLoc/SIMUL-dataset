function result = isOctave()
    result = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end