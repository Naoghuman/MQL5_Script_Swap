# Description

When trading CFDs, there is an overnight fee to pay if a position is held open overnight.
If the overnight fee is negative, then the trader must pay the nightly fee accordingly. If the overnight fee is positive, then the trader is credited the fee.

Positive overnight charges is one of the components of a trading strategy that is very often underestimated.
The size of overnight fees depends on various factors such as broker, position size, market, etc.

I myself calculate with 1%-2% on average for positive overnight charges and 2%-5% for negative overnight charges. So we have a difference of 3%-7%. Let's say 5% for the sake of simplicity.

## Example A (win trade with positive swap)

 - Let's say we realized  a Trade after 5 days with a win from 1,5 RRR (1,5 from the distance Entry - StopLoss).
 - That means our win is 1,5 x N (where N is the loss if we are stopped out) + (5 x 2% (positive swap)).
 - In case we risk 100,00€ in this trade we have now *(1,5 x 100,00€) + (5 x 2,00€) = **160,00€***.

## Example B (win trade with negative swap)
- In example B we have the same trade but with negative swap.
- That means our win result is now *1,5 x N - 5 x 3% = 1,5 x 100,00€ - 5 x 3,00€ = **135,00€***.

## Example C (loss trade with positive swap)
- In example C we have a loss trade so the result is:
- *-1 x N + 5 x 2% = -1 x 100,00€ + 5 x 2,00€ = **-90,00€***.

## Example D (loss trade with negative swap)
- Last we have a loss trade with negative swap.
- *-1 x N - 5 x 3% = -1 x 100,00€ - 5 x 3,00€ = **-115,00€***.

## Conclusion
In our win trade we have a difference from ***25,00€** (160,00€ = +swap; 135,00€ = -swap)*.
In our loss trade we also have a difference from ***25,00€** (-90,00€ = +swap; -115,00€ = -swap)*.

That means in summary we have a difference from **50,00€** in our trades if we trade in context from +swap.
