function key = keyIn_test

kb = HebiKeyboard();
state = read(kb);

if all(state.keys('a'))
    key = 'a';
elseif all(state.keys('b'))
    key = 'b';
elseif all(state.keys('c'))
    key = 'c';
elseif all(state.keys('d'))
    key = 'd';
end
end
