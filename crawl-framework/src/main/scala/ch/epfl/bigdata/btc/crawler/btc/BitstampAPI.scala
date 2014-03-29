package ch.epfl.bigdata.btc.crawler.btc

import Currency._
import BTCeCaseTransaction._
import org.apache.http.client.fluent._
import net.liftweb.json._
import org.joda.time.DateTime





class BitstampAPI(from: Currency, to: Currency) {
  implicit val formats = net.liftweb.json.DefaultFormats
  
  val serverBase = "https://www.bitstamp.net/api/transactions/"
 
	def getInfo() {
    
	}
	
	def getTicker() {
	  
	}
	
	def getTrade(count: Int) : List[Transaction] = {
	  var path = serverBase
	  var json = Request.Get(path).execute().returnContent().asString()
	  
	  var t = parse(json).extract[List[BitstampCaseTransaction]]

	  return t.map(f => new Transaction(from, to, f.price.toDouble, 
	      f.amount.toDouble, f.tid, new DateTime(f.date.toLong), OfferType.BID))
	}
	
	def getDepth() {
	  
	}
}