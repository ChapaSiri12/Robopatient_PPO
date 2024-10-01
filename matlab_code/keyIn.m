kb = HebiKeyboard();

while true
    state = read(kb);
    if all(state.keys('0'))
        disp('a');
        kb.close;
        break;
    elseif all(state.keys('b'))
        disp('b');
        kb.close;
        break;
    elseif all(state.keys('c'))
        disp('c');
        kb.close;
        break;
    elseif all(state.keys('d'))
        disp('d');
        kb.close;
        break;
    end
end