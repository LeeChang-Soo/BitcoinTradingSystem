tweets = []
plotData = []

fakePlot = [[1400076000, 434.5],[1400076500, 434.0],[1400077000, 434.5],[1400077500, 434.0],[1400078000, 434.5]]

$ ->
  ws = new WebSocket $("body").data("ws-url")
  ws.onmessage = (event) ->
    message = JSON.parse event.data
    switch message.type
      when "stockhistory"
        populateStockHistory(message)
      when "stockupdate"
        updateStockData(message)
        updatePrice(message)
      when "EMA"
        updateEMAData(message)
      when "tweet"
      	if message.sentiment != 0
       	  tweets.push message
       	  showTweets()
      else
        console.log(message)

  $("#addsymbolform").submit (event) ->
    event.preventDefault()
    # send the message to watch the stock
    ws.send(JSON.stringify({symbol: $("#addsymboltext").val()}))
    # reset the form
    $("#addsymboltext").val("")
    
    
getPricesFromArray = (data) ->
  (v[1] for v in data)
  
  
getChartArray = (data) ->
  ([i, v] for v, i in data)
  
  
getChartOptions = (data) ->
  series:
    shadowSize: 0
  yaxis:
    min: 400
    max: 410
  xaxis:
    show: true
    #mode: time
    #timeformat: "%Y/%m/%d"


getAxisMin = (data) ->
  Math.min.apply(Math, data) * 0.999
getAxisMax = (data) ->
  Math.max.apply(Math, data) * 1.001

  
  
getXAxisMin = (fulldata) ->
  a = (v[0] for v in fulldata)
  return Math.min.apply(Math, a)
  
getXAxisMax = (fulldata) ->
  a = (v[0] for v in fulldata)
  return Math.max.apply(Math, a)
  
  
populateStockHistory = (message) ->
  
  
  #populates with history, we do not want
  #plot = chart.plot([getChartArray(message.history)], getChartOptions(message.history)).data("plot")
  chart = $("#chart").addClass("chart")
  plot = chart.plot([plotData, fakePlot], getChartOptions(message.history)).data("plot")
  
  #console.log("mesage history", message.history)
  #console.log("data", plot.getData()[0].data)

#compteur de messages recus
window.kl = 0
#taille d'affichage du plot
window.ps = 0


root = exports ? this

#global variable containing plot size
nDataInPlot = 100;

#begin and end times for plot graph
beginTime = 1400043400
endTime = 1500064800

@updatePlotTimeRange = updatePlotTimeRange = () ->
	inputBeginTime = document.getElementsByName('textboxbegintime')[0].value
	inputEndTime = document.getElementsByName('textboxendtime')[0].value
	beginTime = inputBeginTime
	endTime = inputEndTime
	drawValuesInRange(beginTime, endTime)
	#now we have to old values with shifting
	#while (plotData[0][0])


@updatePlotSize = updatePlotSize = () ->
	inputNData = document.getElementsByName('textboxplotsize')[0].value
	if (inputNData >= 1) and (inputNData <= 3000)
	  nDataInPlot = inputNData
	  
	  #redraw graph
	  drawLastValues(nDataInPlot)
	else
	  alert "invalid value, outside of : [1,3000]"
	window.ps = plotData.length
  
updateStockData = (message) ->
	plotData.push([message.time, message.price])

updateEMAData = (message) ->
	console.log("EMA JSON Array", message.values);

#redraws the plot every second, regardless of data pushed (to prevent freezes)  
setInterval ( ->
  drawLastValues(nDataInPlot)
  #drawValuesInRange(beginTime, endTime)
), 1000

    
drawLastValues = (numberOfValues) ->
	plotData.sort()
	#copying the array
	lastPlotData = clone(plotData)
	#resizing dataset locally
	while (lastPlotData.length >= numberOfValues)
	  lastPlotData.shift()
	  
	if ($("#chart").size() > 0)
      plot = $("#chart").data("plot")
      plot.setData([lastPlotData, fakePlot])
      #data2 = plot.getData()[0].data
      data = getPricesFromArray(lastPlotData)
	#setting the x axis
  
	xaxes = plot.getOptions().xaxes[0]
	xaxes.min = getXAxisMin(lastPlotData)
	xaxes.max = getXAxisMax(lastPlotData)
	plot.setupGrid()
    
    # update the yaxes if either the min or max is now out of the acceptable range
	yaxes = plot.getOptions().yaxes[0]
	#if ((getAxisMin(data) < yaxes.min) || (getAxisMax(data) > yaxes.max))
    # reseting yaxes
	yaxes.min = getAxisMin(data)*1
	yaxes.max = getAxisMax(data)*1
	plot.setupGrid()
	# redraw the chart
	plot.draw()
	#console.log("data", data)


drawValuesInRange = (beginRange, endRange) ->
	
	#copying the array
	rangePlotData = clone(plotData)
	#resizing dataset locally
	while (rangePlotData[0][0] <= beginRange)
	  rangePlotData.shift()
	while (rangePlotData[rangePlotData.length - 1][0] >= endRange)
	  rangePlotData.pop()
	console.log("range from", beginRange)
	console.log("range to", endRange)  
	console.log("n. of vals to draw for range", rangePlotData.length)
	  
	if ($("#chart").size() > 0)
      plot = $("#chart").data("plot")
      plot.setData([rangePlotData])
      #data2 = plot.getData()[0].data
      data = getPricesFromArray(rangePlotData)
	#setting the x axis
	xaxes = plot.getOptions().xaxes[0]
	xaxes.min = getXAxisMin(rangePlotData)
	xaxes.max = getXAxisMax(rangePlotData)
	plot.setupGrid()
    
    # update the yaxes if either the min or max is now out of the acceptable range
	yaxes = plot.getOptions().yaxes[0]
	#if ((getAxisMin(data) < yaxes.min) || (getAxisMax(data) > yaxes.max))
    # reseting yaxes
	yaxes.min = getAxisMin(data)*1
	yaxes.max = getAxisMax(data)*1
	plot.setupGrid()
	# redraw the chart
	plot.draw()
	#console.log("data", data)
	
 #tweet array 
#max tweets
updatePrice = (message) ->
	document.getElementById('price').innerHTML =  '$' + message.price.toFixed(2)
    
showTweets = () ->
	formattedTweets = (showtweet(tweet) for tweet in tweets).reduceRight (x, y) -> x + "\n" + y
	document.getElementById('tweetList').innerHTML = formattedTweets
    
showtweet = (message) ->
	sentiment = message.sentiment
	str = 
	if sentiment == -1
		str = '<div class="negtweet" id="clickable">'
	if sentiment == 1
		str = '<div class="postweet" id="clickable">'
	
	str += message.symbol
	str += '<i class="icon-info-sign" id="info">click</i></div>'
	return str

clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  if obj instanceof Date
    return new Date(obj.getTime()) 

  if obj instanceof RegExp
    flags = ''
    flags += 'g' if obj.global?
    flags += 'i' if obj.ignoreCase?
    flags += 'm' if obj.multiline?
    flags += 'y' if obj.sticky?
    return new RegExp(obj.source, flags) 

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance   
