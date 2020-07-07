//+------------------------------------------------------------------+
//|                                        HalfTrendFollowColour.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int      TakeProfit=400;
input int      StopLoss=400;
input double   LotSize=0.2;
input bool     UseMFI=true;
input int      Slippage=20;
input int      MagicNumber=5555;

bool sells_open = false;
bool buys_open = false;
bool orders_open = false;
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
//---

      double buy = getHalfTrendStatus(5, 1);
      double sell = getHalfTrendStatus(6, 1);
      if(sell != EMPTY_VALUE && sell < 2147483647) {         
         if(orders_open == false) {            
            OrderSend(_Symbol,OP_SELL,LotSize,Bid,Slippage,0,0,"SELL",MagicNumber); 
            sells_open = true;
            buys_open = false;
            orders_open = true;
         } else if(orders_open == true && buys_open == true) {
            CloseAllOpenTrades();
            OrderSend(_Symbol,OP_SELL,LotSize,Bid,Slippage,0,0,"SELL",MagicNumber); 
            sells_open = true;
            buys_open = false;
            orders_open = true;
         }
      } else if(buy != EMPTY_VALUE && buy < 2147483647) {
         if(orders_open == false) {            
            OrderSend(_Symbol,OP_BUY,LotSize,Ask,Slippage,0,0,"BUY",MagicNumber);  
            sells_open = false;
            buys_open = true;   
            orders_open = true;         
         } else if(orders_open == true && sells_open == true) {
            CloseAllOpenTrades();
            OrderSend(_Symbol,OP_BUY,LotSize,Ask,Slippage,0,0,"BUY",MagicNumber);
            sells_open = false;
            buys_open = true; 
            orders_open = true;
         }
      }

   
  }
//+------------------------------------------------------------------+

void CloseAllOpenTrades() {
   for(int i=OrdersTotal(); i>=0; i--) {
      if(OrderSelect(i, SELECT_BY_POS) == true) {
         if(OrderSymbol() == Symbol()) {
            OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
            OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
         }
      }
   }
}

double getHalfTrendStatus(int first, int second) {
   return(iCustom(NULL,0,"half-trend nrp", 2, false, true, first, second));
}

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