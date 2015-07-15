//+------------------------------------------------------------------+
//|                                                       GapV300.mq5|
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "4.00"


#include <Trade\SymbolInfo.mqh>
#include <Expert\Trailing\TrailingFixedPips.mqh>

#include <Lib CisNewBar.mqh>
CisNewBar current_chart; // instance of the CisNewBar class: current chart

 
//-----------------------------------------------

#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33

//-------------------------------------------------

/* Spreads
#define EURUSD 3
#define USDJPY 4
#define GBPUSD 5
#define USDCHF 5
#define USDCAD 3
#define AUDUSD 4
#define NZDUSD 5
//-------------------------------------------------
*/
enum CHOICE
{
   no,
   yes,
};

input float PROFIT;
input float SLFACTOR;
input CHOICE YESNO=no;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

datetime dtLastDate;
int OnInit()
{
     
   //int const PERIODICITY = PeriodSeconds(PERIOD_CURRENT);   
   //EventSetTimer(PERIODICITY+1);
   
   //double MinStopDist = MarketInfoMQL4(Symbol(),MODE_STOPLEVEL)* Point();
   //Alert("MinStopDist: ",MinStopDist);
      
   return(0);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   //EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      //CTrailingFixedPips *trailing=new CTrailingFixedPips;
      //traling stop
      //trailing.StopLevel(10);
      //trailing.ProfitLevel(5);
      int period_seconds=PeriodSeconds(_Period);                     // Number of seconds in current chart period
      datetime new_time=TimeCurrent()/period_seconds*period_seconds; // Time of bar opening on current chart
      if(current_chart.isNewBar(new_time)) OnNewBar();               // When new bar appears - launch the NewBar event handler
  }
//+------------------------------------------------------------------+

void OnNewBar()
{
   
  //Alert("OnNewBar:",dtLastDate ); 
    
  double dSpread = 0;
  MqlTick last_tick;
  double MinStopDist = MarketInfoMQL4(Symbol(),MODE_STOPLEVEL) * Point();
  if(SymbolInfoTick(Symbol(),last_tick))
  {
     double dAsk = NormalizeDouble(last_tick.ask,Digits());
     double dBid = NormalizeDouble(last_tick.bid,Digits());
     dSpread = NormalizeDouble((dAsk-dBid), Digits());
  }
     
     //-- define the variable "rates"  
   MqlRates rates [];
   
   //-- elements will be indexed like in timeseries.  
  ArraySetAsSeries(rates,true);  
   
    //for prod
   //int copied=CopyRates(Symbol(),PERIOD_M15,0,2,rates);
   
   //for test
   int copied=CopyRates(Symbol(),PERIOD_CURRENT,TimeCurrent(),2,rates);   
   //dSpread = GetSpread();
  
   //if(rates[0].time != dtLastDate)
   //{
      OrderTypeSell(rates, dSpread, MinStopDist);
      OrderTypeBuy(rates, dSpread, MinStopDist);
      dtLastDate = rates[0].time;
   //}  
}

/*int GetSpread()
{
   int iSpread;
   switch(EnumToString(Symbol())
   {
      case "EURUSD":
      {
         iSpread = EURUSD; 
         break;
      }
      
      case "USDJPY":
      {
         iSpread = USDJPY; 
         break;
      }
      
      case "GBPUSD":
      {
         iSpread = GBPUSD; 
         break;
      }
      
      case "USDCHF":
      {
         iSpread = USDCHF; 
         break;
      }
      
      case "USDCAD":
      {
         iSpread = USDCAD; 
         break;
      }
      
      case "AUDUSD":
      {
         iSpread = AUDUSD; 
         break;
      }
      
      case "NZDUSD":
      {
         iSpread = NZDUSD; 
         break;
      }
   }
}*/

void OrderTypeSell(MqlRates &rates [], double dSpread, double MinStopDist)
{
   //Alert("OrderTypeSell");
   
   MqlTradeRequest mrequest;
   MqlTradeResult mresult;
   MqlTradeCheckResult check_result;
   MqlTick last_tick;
   SymbolInfoTick(Symbol(),last_tick);
   double dBid = NormalizeDouble(last_tick.bid,Digits());
   double sl;
   double tp;
   double SpreadTemp;
   
   if(rates[0].open - NormalizeDouble(rates[1].high,Digits()) > PROFIT)
   {
      SymbolInfoTick(Symbol(),last_tick);
      Alert("OrderSell -> PRICE: ",dBid," last_tick.bid:",last_tick.bid," HIGH: ",NormalizeDouble(rates[1].high,Digits())," SL: ",NormalizeDouble(dBid + dSpread + SLFACTOR,Digits())," TP: ",NormalizeDouble(rates[1].high,Digits()),"Time0: ",rates[0].time,"Time1:",rates[1].time);
      //SpreadTemp = MarketInfoMQL4(Symbol(),MODE_SPREAD)* Point();
      //Alert("SpreadTemp: ",SpreadTemp);
      
      sl = NormalizeDouble(dBid + dSpread + SLFACTOR,Digits()); 
      tp = NormalizeDouble(rates[1].high,Digits());
      //Alert("sl-dBid:",sl-dBid);
      if(YESNO == 1)
      {
         if((sl-dBid) <= MinStopDist)
         {
            
            sl = dBid + MinStopDist;
            Alert("in sl if: ",sl);
         }    
         
         //Alert("dBid-tp: ",dBid-tp);  
         if((dBid-tp) <= MinStopDist)
         {
            tp = dBid - MinStopDist;
            Alert("in tp if: ",tp);
         }
      }
      mrequest.action = TRADE_ACTION_DEAL;                                 // immediate order execution
      mrequest.price = dBid;                                    // latest Bid price
      mrequest.sl = sl;                      // Stop Loss 
      mrequest.tp = tp;                                         // Take Profit
      mrequest.symbol = _Symbol;                                           // currency pair
      mrequest.volume = 1.00;                                              // number of lots to trade
      mrequest.magic = 12345;                                              // Order Magic Number
      mrequest.type= ORDER_TYPE_SELL;                                      // Sell Order
      mrequest.type_filling = ORDER_FILLING_AON;                           // Order execution type
      mrequest.deviation=100;                                                // Deviation from current price
      
     if(!OrderCheck(mrequest,check_result))
     {
         Alert("The trade request didn't pass check by the OrderCheck() function ",check_result.comment);
         
     }
     else
     {
         OrderSend(mrequest,mresult);
         /*ResetLastError();*/
         //--- send order
      
      
      /*
         // get the result code
         if(mresult.retcode==10009 || mresult.retcode==10008) //Request is completed or order placed
         {
            if(OrderSend(mrequest,mresult))
            {
               Alert("SELL: ",NormalizeDouble((rates[0].open - rates[1].high), Digits()));
               Alert("SELL: ",NormalizeDouble((dBid - rates[1].high), Digits()));
               //Alert("I= ",i," OPEN: ",rates[0].open," HIGH: ",rates[1].high," SL: ",rates[0].open + spread + 0.002," TP: ",rates[1].high);
               //Alert(outBefor);
               //Alert(out);
            Alert("A Buy order has been successfully placed with Ticket#:",mresult.order,"!!");
            }
            else
            {
               Alert("The Buy order request could not be completed -error:",GetLastError());
               ResetLastError();           
               //return;
            }
         
         }
         */
     }
   }      
}

void OrderTypeBuy(MqlRates &rates [], double dSpread, double MinStopDist)
{
   //Alert("OrderTypeBuy");
   
   MqlTradeRequest mrequest;
   MqlTradeResult mresult;
   MqlTradeCheckResult check_result;
   
   MqlTick last_tick;
   SymbolInfoTick(Symbol(),last_tick);

   double dAsk = NormalizeDouble(last_tick.ask,Digits());
   double sl;
   double tp;
   double SpreadTemp;
  
   if(NormalizeDouble(rates[1].low,Digits()) - rates[0].open > PROFIT)
   {
      SymbolInfoTick(Symbol(),last_tick);
      Alert("OrderBuy -> PRICE: ",dAsk," last_tick.ask: ", last_tick.ask," LOW1: ",NormalizeDouble(rates[1].low,Digits())," LOW0: ",NormalizeDouble(rates[0].low,Digits())," SL: ",NormalizeDouble(dAsk - dSpread - SLFACTOR,Digits())," TP: ",NormalizeDouble(rates[1].low,Digits()));
      //SpreadTemp = MarketInfoMQL4(Symbol(),MODE_SPREAD)* Point();
      //Alert("SpreadTemp: ",SpreadTemp);
      
      sl = NormalizeDouble(((dAsk - dSpread) - SLFACTOR),Digits()); 
      tp = NormalizeDouble(rates[1].low,Digits());      
      if(YESNO == 1)
      {
         //Alert("dAsk-sl:",dAsk-sl);
         if((dAsk-sl) <= MinStopDist)
         {
            
            sl = dAsk - MinStopDist;
            Alert("in sl if: ",sl);
         } 
 
         //Alert("tp-dAsk: ",tp-dAsk);  
         if((tp-dAsk) <= MinStopDist)
         {
            tp = dAsk + MinStopDist;
            Alert("in tp if: ",tp);
         }
      }
      mrequest.sl = sl;                      // Stop Loss
      mrequest.tp = tp;                      // Take Profit
      mrequest.action = TRADE_ACTION_DEAL;                                 // immediate order execution
      mrequest.price = dAsk;
      mrequest.symbol = _Symbol;                                           // currency pair
      mrequest.volume = 1.00;                                              // number of lots to trade
      mrequest.magic = 12345;                                              // Order Magic Number
      mrequest.type= ORDER_TYPE_BUY;                                       // Sell Order
      mrequest.type_filling = ORDER_FILLING_AON;                           // Order execution type
      mrequest.deviation=100;                                                // Deviation from current price
      
     if(!OrderCheck(mrequest,check_result))
     {
         Alert("The trade request didn't pass check by the OrderCheck() function ",check_result.comment);
         
     }
     else
     {
         OrderSend(mrequest,mresult);
         /*ResetLastError();*/
         //--- send order
      
      
      /*
         // get the result code
         if(mresult.retcode==10009 || mresult.retcode==10008) //Request is completed or order placed
         {
            if(OrderSend(mrequest,mresult))
            {
               Alert("SELL: ",NormalizeDouble((rates[0].open - rates[1].high), Digits()));
               //Alert("I= ",i," OPEN: ",rates[0].open," HIGH: ",rates[1].high," SL: ",rates[0].open + spread + 0.002," TP: ",rates[1].high);
               //Alert(outBefor);
               //Alert(out);
            Alert("A Buy order has been successfully placed with Ticket#:",mresult.order,"!!");
            }
            else
            {
               Alert("The Buy order request could not be completed -error:",GetLastError());
               ResetLastError();           
               //return;
            }
         
         }
         */      
      }
   }      
}

double MarketInfoMQL4(string symbol,
                      int type)
  {
   switch(type)
     {
      case MODE_LOW:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTLOW));
      case MODE_HIGH:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTHIGH));
      case MODE_TIME:
         return(SymbolInfoInteger(symbol,SYMBOL_TIME));
      case MODE_POINT:
         return(SymbolInfoDouble(symbol,SYMBOL_POINT));
      case MODE_DIGITS:
         return(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      case MODE_SPREAD:
         return(SymbolInfoInteger(symbol,SYMBOL_SPREAD));
      case MODE_STOPLEVEL:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
      case MODE_LOTSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE));
      case MODE_TICKVALUE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE));
      case MODE_TICKSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
      case MODE_SWAPLONG:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG));
      case MODE_SWAPSHORT:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT));
      case MODE_STARTING:
         return(0);
      case MODE_EXPIRATION:
         return(0);
      case MODE_TRADEALLOWED:
         return(0);
      case MODE_MINLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN));
      case MODE_LOTSTEP:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP));
      case MODE_MAXLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX));
      case MODE_SWAPTYPE:
         return(SymbolInfoInteger(symbol,SYMBOL_SWAP_MODE));
      case MODE_PROFITCALCMODE:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE));
      case MODE_MARGINCALCMODE:
         return(0);
      case MODE_MARGININIT:
         return(0);
      case MODE_MARGINMAINTENANCE:
         return(0);
      case MODE_MARGINHEDGED:
         return(0);
      case MODE_MARGINREQUIRED:
         return(0);
      case MODE_FREEZELEVEL:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL));

      default: return(0);
     }
   return(0);
  }