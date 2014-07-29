/FSD/ { print $0 }
BEGIN {ARR="1 2 3 4 5"}
{for (i=1;i<=5;i++) print ARR[i]}

