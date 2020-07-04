//+------------------------------------------------------------------+
//|                                                  My First EA.mq4 |
//|                                     MQL4 tutorial on quivofx.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.02"
#property strict
//--- input parameters
input int      TakeProfit=500;
input int      StopLoss=500;
input double   LotSize=0.1;
input int      Slippage=30;
input int      MagicNumber=5555;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

     if(TotalOpenOrders() == 0) {
     
     bool buys_open = false;
     bool sells_open = false; 
     double buy;
     double sell;
     double fast_uptrend;
     double fast_downtrend;
     double slow_uptrend;
     double slow_downtrend;
     
     //buy = iCustom(NULL,0,"half-trend nrp", 2, false, true, 5, 1);
     //sell = iCustom(NULL,0,"half-trend nrp", 3, false, true, 6, 1);
     
     buy = getHalfTrendStatus(5, 1);
     sell = getHalfTrendStatus(6, 1);
     fast_uptrend = getFastTrendFilter(1, 1);
     fast_downtrend = getFastTrendFilter(0, 1);
     slow_uptrend = getSlowTrendFilter(0, 1);
     slow_downtrend = getSlowTrendFilter(1, 1);
     
     Print("slow_uptrend : " + slow_uptrend);
     Print("slow_downtrend : " + slow_downtrend);    
     
     
     if(buy != EMPTY_VALUE && buy < 2147483647 && fast_uptrend < 2147483647 && slow_uptrend < 2147483647){
         // close open shorts
         Print("buy: " + buy + "fast_uptrend: " + fast_uptrend + "slow_uptrend: " + slow_uptrend);
         // Open Buy Order
         OrderSend(_Symbol,OP_BUY,LotSize,Ask,Slippage,Ask-StopLoss*_Point,Ask+TakeProfit*_Point,"BUY",MagicNumber);          
         // set buys_open flag to true    
         buys_open = true;  
      } else if(sell != EMPTY_VALUE && sell < 2147483647 && fast_downtrend < 2147483647 && slow_downtrend < 2147483647){
         // close open buys
         Print("sell: " + sell + fast_downtrend + "slow_downtrend: " + slow_downtrend);         
         //Open Sell Order         
         OrderSend(_Symbol,OP_SELL,LotSize,Bid,Slippage,Bid+StopLoss*_Point,Bid-TakeProfit*_Point,"SELL",MagicNumber);//Opening Sell  
         // set buys_open flag to true    
         sells_open = true;        
      } 
           
     }
   
  }
//+------------------------------------------------------------------+

double getHalfTrendStatus(int first, int second) {
   return(iCustom(NULL,0,"half-trend nrp", 2, false, true, first, second));
}

double getFastTrendFilter(int first, int second) {
   return(iCustom(NULL,0,"vh", first, second));
}

double getSlowTrendFilter(int first, int second) {
   return(iCustom(NULL,0,"hull_moving_average_2.0_amp_sr_lines_arrows", "Current time frame", 34, 0, 2.0, false, first, second));
}


//+------------------------------------------------------------------------+
//| Closes everything
//+------------------------------------------------------------------------+
void CloseAll()
{
   int i;
   bool result = false;

   while(OrdersTotal()>0)
   {
      // Close open positions first to lock in profit/loss
      for(i=OrdersTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i, SELECT_BY_POS)==false) continue;

         result = false;
         if ( OrderType() == OP_BUY)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 15, Red );
         if ( OrderType() == OP_SELL)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 15, Red );
         
      }
      for(i=OrdersTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i, SELECT_BY_POS)==false) continue;

         result = false;
         if ( OrderType()== OP_BUYSTOP)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_SELLSTOP)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_BUYLIMIT)  result = OrderDelete( OrderTicket() );
         if ( OrderType()== OP_SELLLIMIT)  result = OrderDelete( OrderTicket() );
         
      }
      Sleep(1000);
   }
}
   
// Check if there is a new bar
bool IsNewBar()   
{        
      static datetime RegBarTime=0;
      datetime ThisBarTime = Time[0];
      
      if (ThisBarTime == RegBarTime)
      {
         return(false);
      }
      else
      {
         RegBarTime = ThisBarTime;
         return(true);
      }
}   
   
// Returns the number of total open orders for this Symbol and MagicNumber
int TotalOpenOrders()
{
   int total_orders = 0;
   
   for(int order = 0; order < OrdersTotal(); order++) 
   {
      if(OrderSelect(order,SELECT_BY_POS,MODE_TRADES)==false) break;
      
      if(OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol)
         {
            total_orders++;
         }
   }
   
   return(total_orders);
}