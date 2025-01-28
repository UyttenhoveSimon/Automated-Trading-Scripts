//@version=6
indicator("SPY Option Strategy", overlay=true)

// Input for pre-market session symbol and timeframe
pm_symbol = input.symbol("SPY", "Pre-Market Symbol")
pm_tf = input.timeframe("5", "Pre-Market Timeframe")

// Get yesterday's close price
yesterday_close = request.security(syminfo.tickerid, "D", close[1])

// Get today's pre-market price
pm_price = request.security(pm_symbol, pm_tf, close)

// Determine the action
var strategyText = ""
if (yesterday_close > pm_price)
    strategyText := "Buy PUT at today's opening price with strike at current price"
else if (yesterday_close < pm_price)
    strategyText := "Buy CALL at today's opening price with strike at current price"
else
    strategyText := "No action"

// Plot on the chart
bg_color = color.blue
if (strategyText == "Buy PUT at today's opening price with strike at current price")
    bg_color := color.red
else if (strategyText == "Buy CALL at today's opening price with strike at current price")
    bg_color := color.green

bgcolor(bg_color)

label.new(bar_index, high, strategyText, style=label.style_label_down, color=color.new(color.white, 90))
