//@version=5
strategy("EMA Position Strategy with Full Portfolio", overlay=true, default_qty_type=strategy.cash, default_qty_value=100000)

// Input parameters
fastLength = input(9, "Fast EMA Length")
slowLength = input(21, "Slow EMA Length")
sustainedPeriods = input(5, "Sustained Crossover Periods")

// Calculate EMAs
fastEMA = ta.ema(close, fastLength)
slowEMA = ta.ema(close, slowLength)

// Define conditions
isAbove = fastEMA > slowEMA
isBelow = fastEMA < slowEMA

// Check if condition has been true for the required number of periods
sustainedAbove = ta.barssince(not isAbove) >= sustainedPeriods
sustainedBelow = ta.barssince(not isBelow) >= sustainedPeriods

// Determine position
var float position = 0
if (sustainedAbove and position <= 0)
    position := 1
else if (sustainedBelow and position >= 0)
    position := -1

// Calculate position size based on the full equity
positionSize = strategy.equity / close

// Ensure positions are closed before new entries
if (position == 1) 
    if (strategy.position_size < 0) 
        strategy.close("Short")
    if (strategy.position_size == 0)
        strategy.entry("Long", strategy.long, qty=positionSize)
        
else if (position == -1) 
    if (strategy.position_size > 0) 
        strategy.close("Long")
    if (strategy.position_size == 0)
        strategy.entry("Short", strategy.short, qty=positionSize)

// Plot EMAs
plot(fastEMA, color=color.blue, title="Fast EMA")
plot(slowEMA, color=color.red, title="Slow EMA")

// Plot entry points
plotshape(position == 1 and position[1] <= 0, title="Long Entry", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(position == -1 and position[1] >= 0, title="Short Entry", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)

// Plot sustained crossover
bgcolor(sustainedAbove ? color.new(color.green, 90) : sustainedBelow ? color.new(color.red, 90) : na)
