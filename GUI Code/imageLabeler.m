function name = imageLabeler(label)
% This Function returns the character coressponding to label number
% It is necessary to keep this function in the same directory with the main code
caps = ['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z'];
smalls = ['a' 'b' 'd' 'e' 'f' 'g' 'h' 'n' 'q' 'r' 't'];
if 0<=label&&label<=9
    name=label;
elseif 10<=label&&label<=35
    name=caps(label-9);
elseif 36<=label&&label<=46
    name=smalls(label-35);
end
