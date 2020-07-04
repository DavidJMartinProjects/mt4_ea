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
     
     buy = iCustom(NULL,0,"half-trend nrp", 2, false, true, 5, 1);
     sell = iCustom(NULL,0,"half-trend nrp", 3, false, true, 6, 1);
     
     if(buy != EMPTY_VALUE && sell > 1){
         // close open shorts
         Print("buy: " + buy);
         // Open Buy Order
         OrderSend(_Symbol,OP_BUY,LotSize,Ask,Slippage,Ask-StopLoss*_Point,Ask+TakeProfit*_Point,"BUY",MagicNumber);          
         // set buys_open flag to true    
         buys_open = true;  
      } else if(sell != EMPTY_VALUE && sell < 1){
         // close open buys
         Print("sell: " + sell);         
         //Open Sell Order         
         OrderSend(_Symbol,OP_SELL,LotSize,Bid,Slippage,Bid+StopLoss*_Point,Bid-TakeProfit*_Point,"SELL",MagicNumber);//Opening Sell  
         // set buys_open flag to true    
         sells_open = true;        
      } 
           
     }
   
  }
//+------------------------------------------------------------------+

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