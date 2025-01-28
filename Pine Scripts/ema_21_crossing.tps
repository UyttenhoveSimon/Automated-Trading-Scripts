//@version=5
strategy("21 EMA vs Price Strategy with Stop Loss", overlay=true, default_qty_type=strategy.cash, initial_capital=100000)

// Input parameters
emaLength = input(21, "EMA Length")
sustainedPeriods = input(5, "Sustained Crossover Periods")
riskPercent = input.float(10.0, "Percent of Portfolio to Risk", minval=1, maxval=100, step=0.1)
stopLossPercent = input.float(5.0, "Stop Loss Percentage", minval=0.1, maxval=20, step=0.1)

// Calculate EMA
ema = ta.ema(close, emaLength)

// Define conditions
isAbove = close > ema
isBelow = close < ema

// Check if condition has been true for the required number of periods
sustainedAbove = ta.barssince(not isAbove) >= sustainedPeriods
sustainedBelow = ta.barssince(not isBelow) >= sustainedPeriods

// Determine position
var float position = 0
if (sustainedAbove and position <= 0)
    position := 1
else if (sustainedBelow and position >= 0)
    position := -1

// Calculate position size
riskAmount = (riskPercent / 100) * strategy.equity
unitsToTrade = riskAmount / close

// Calculate stop loss prices
longStopPrice = strategy.position_avg_price * (1 - stopLossPercent / 100)
shortStopPrice = strategy.position_avg_price * (1 + stopLossPercent / 100)

// Execute trades
if (position == 1 and strategy.position_size <= 0)
    strategy.close("Short")
    strategy.entry("Long", strategy.long, qty=unitsToTrade)
    strategy.exit("Long Stop Loss", "Long", stop=longStopPrice)
else if (position == -1 and strategy.position_size >= 0)
    strategy.close("Long")
    strategy.entry("Short", strategy.short, qty=unitsToTrade)
    strategy.exit("Short Stop Loss", "Short", stop=shortStopPrice)

// Update stop loss for existing positions
if (strategy.position_size > 0)
    strategy.exit("Long Stop Loss", "Long", stop=longStopPrice)
else if (strategy.position_size < 0)
    strategy.exit("Short Stop Loss", "Short", stop=shortStopPrice)

// Plot EMA
plot(ema, color=color.blue, title="21 EMA")

// Plot entry points
plotshape(position == 1 and position[1] <= 0, title="Long Entry", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(position == -1 and position[1] >= 0, title="Short Entry", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)

// Plot stop loss levels
plot(strategy.position_size > 0 ? longStopPrice : na, color=color.red, style=plot.style_linebr, linewidth=2, title="Long Stop Loss")
plot(strategy.position_size < 0 ? shortStopPrice : na, color=color.red, style=plot.style_linebr, linewidth=2, title="Short Stop Loss")

// Plot sustained crossover
bgcolor(sustainedAbove ? color.new(color.green, 90) : sustainedBelow ? color.new(color.red, 90) : na)