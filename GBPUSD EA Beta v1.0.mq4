//+------------------------------------------------------------------+
//|                                                  My First EA.mq4 |
//|                                     MQL4 tutorial on quivofx.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.02"
#property strict

const double opening_balance = AccountBalance();
double balance_after_last_trade = AccountBalance();

//--- input parameters
input int      TakeProfit=400;
input int      StopLoss=400;
input double   LotSize=0.2;
input int      Slippage=20;
input int      MagicNumber=5555;

extern string __c8="----------------------------------";
extern bool    KeepTextOnTop     = true;//Disable the chart in foreground CrapTx setting so the candles do not obscure the text
extern int     DisplayX          = 100;
extern int     DisplayY          = 100;
extern int     fontSise          = 8;
extern string  fontName          = "Courier New";
extern color   colour            = Yellow;

int orderTicket = 0;
double trades_taken = 0;
string day_of_week = "";

bool buys_open = false;
bool sells_open = false;

int count_wins = 0;
int count_losses = 0;

double buy;
double sell;
double fast_uptrend;
double fast_downtrend;
double slow_uptrend;
double slow_downtrend;
double buy_entry_signal;
double sell_entry_signal;

int DisplayCount = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {     
     getDayOfWeek();
     if(tradingAllowed() == true) {
         showDashboard();         
         if(TotalOpenOrders() == 0) {

             buy = getHalfTrendStatus(5, 1);
             sell = getHalfTrendStatus(6, 1);
             fast_uptrend = getFastTrendFilter(1, 1);
             fast_downtrend = getFastTrendFilter(0, 1);
             slow_uptrend = getSlowTrendFilter(0, 1);
             slow_downtrend = getSlowTrendFilter(1, 1);

             if(buy != EMPTY_VALUE && buy < 2147483647 && fast_uptrend < 2147483647 && slow_uptrend < 2147483647){
                 orderTicket = OrderSend(_Symbol,OP_BUY,LotSize,Ask,Slippage,Ask-StopLoss*_Point,Ask+TakeProfit*_Point,"BUY",MagicNumber);
                 drawTradeBox(Ask, Ask-StopLoss*_Point, Ask+TakeProfit*_Point, "BUY");
                 trades_taken++;
                 buys_open = true;
             } else if(sell != EMPTY_VALUE && sell < 2147483647 && fast_downtrend < 2147483647 && slow_downtrend < 2147483647) {
                 orderTicket = OrderSend(_Symbol,OP_SELL,LotSize,Bid,Slippage,Bid+StopLoss*_Point,Bid-TakeProfit*_Point,"SELL",MagicNumber);//Opening Sell
                 drawTradeBox(Bid, Bid+StopLoss*_Point, Bid-TakeProfit*_Point, "SELL");
                 trades_taken++;
                 sells_open = true;
             }
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
   return(iCustom(NULL,0,"hull_moving_average_2.0_amp_sr_lines_arrows", "Current time frame", 144, 0, 1.0, false, first, second));
}

double getEntrySignal(int first, int second) {
   return(iCustom(NULL,0,"ScalpCycle", false, first, second));
}

void drawTradeBox(double entry, double stoploss, double takeprofit, string tradeType) {
   
   if(tradeType == "BUY") {
      ObjectDelete("StopLoss");
      ObjectCreate("StopLoss",OBJ_RECTANGLE, 0, Time[0],entry,Time[30],stoploss);
      ObjectSetInteger(ChartID(),"StopLoss",OBJPROP_COLOR,clrLightPink);
      ObjectSetInteger(ChartID(),"StopLoss",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(ChartID(),"StopLoss",OBJPROP_BACK,true);
   
      ObjectDelete("TakeProfit");
      ObjectCreate("TakeProfit",OBJ_RECTANGLE, 0, Time[0],entry,Time[30],takeprofit);
      ObjectSetInteger(ChartID(),"TakeProfit",OBJPROP_COLOR,clrPaleGreen);
      ObjectSetInteger(ChartID(),"TakeProfit",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(ChartID(),"TakeProfit",OBJPROP_BACK,true);
   } else if(tradeType == "SELL") {
      ObjectDelete("TakeProfit");
      ObjectCreate("TakeProfit",OBJ_RECTANGLE, 0, Time[0],entry,Time[30],stoploss);
      ObjectSetInteger(ChartID(),"TakeProfit",OBJPROP_COLOR,clrLightPink);
      ObjectSetInteger(ChartID(),"TakeProfit",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(ChartID(),"TakeProfit",OBJPROP_BACK,true);
   
      ObjectDelete("StopLoss");
      ObjectCreate("StopLoss",OBJ_RECTANGLE, 0, Time[0],entry,Time[30],takeprofit);
      ObjectSetInteger(ChartID(),"StopLoss",OBJPROP_COLOR,clrPaleGreen);
      ObjectSetInteger(ChartID(),"StopLoss",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(ChartID(),"StopLoss",OBJPROP_BACK,true);
   
   }
   ChartRedraw();
   Sleep(1000);
}

void getDayOfWeek() {   
   string day = DayOfWeek();
   if(day == 0) {
      day_of_week = "Sunday";
   } else if(day == 1) {
      day_of_week = "Monday";
   } else if(day == 2) {
      day_of_week = "Tuesday";
   } else if(day == 3) {
      day_of_week = "Wednesday";
   } else if(day == 4) {
      day_of_week = "Thursday";
   } else if(day == 5) {
      day_of_week = "Friday";
   } else if(day == 6) {
      day_of_week = "Saturday";
   }   
}

void showDashboard() {

//   string comment = 
//      "\n" + 
//      "Current Day: " + day_of_week + "\n" +
//      "Current Time: " + TimeCurrent() + "\n" +
//      "\n" + 

      UpdateWinLossStatus();
      
      // Build Dashboard Messages      
      DisplayCount=0;
      AddDashBoardMessage("---------------------------");
      AddDashBoardMessage("The Coon EA Dashboard");
      AddDashBoardMessage("---------------------------");
      AddDashBoardMessage("");      
      AddDashBoardMessage("Current Day: " + day_of_week);
      AddDashBoardMessage("Trades Taken: " + trades_taken);
      AddDashBoardMessage("");
      AddDashBoardMessage("Winners: " + count_wins);
      AddDashBoardMessage("Losers: " + count_losses);
      AddDashBoardMessage("");
      AddDashBoardMessage("Profit this session: " + DoubleToString(( AccountBalance() - opening_balance ), 2));
      AddDashBoardMessage("---------------------------");
  
  
}

void UpdateWinLossStatus() {
   if(balance_after_last_trade != AccountBalance() && balance_after_last_trade - AccountBalance() < 20 ) {
      count_wins++;      
   }
   else if(balance_after_last_trade != AccountBalance() && balance_after_last_trade - AccountBalance() > 20 ) {
      count_losses++;
   }      
   balance_after_last_trade = AccountBalance();   
}

void AddDashBoardMessage(string message) {

   DisplayCount++;
   Display(message);   
}

void Display(string text)
{
  string lab_str = "EA-" + IntegerToString(DisplayCount);  
  double ofset = 0;  
  
  ObjectCreate("EA-BG",OBJ_RECTANGLE_LABEL,0,0,0);
  ObjectSet("EA-BG", OBJPROP_XDISTANCE, DisplayX-20);
  ObjectSet("EA-BG", OBJPROP_YDISTANCE, DisplayY-10);
  ObjectSet("EA-BG", OBJPROP_XSIZE,252);
  ObjectSet("EA-BG", OBJPROP_YSIZE,250);
  ObjectSet("EA-BG", OBJPROP_BGCOLOR,clrBlack);
   //  ObjectSet("EA-BG", OBJPROP_BORDER_TYPE,BORDER_SUNKEN);
  ObjectSet("EA-BG", OBJPROP_CORNER,CORNER_LEFT_UPPER);
  ObjectSet("EA-BG", OBJPROP_STYLE,STYLE_SOLID);
  ObjectSet("EA-BG", OBJPROP_COLOR,colour);
  ObjectSet("EA-BG", OBJPROP_WIDTH,0);
  ObjectSet("EA-BG", OBJPROP_BACK,false);

  ObjectCreate(lab_str, OBJ_LABEL, 0, 0, 0);
  ObjectSet(lab_str, OBJPROP_CORNER, 0);
  ObjectSet(lab_str, OBJPROP_XDISTANCE, DisplayX + ofset);
  ObjectSet(lab_str, OBJPROP_YDISTANCE, DisplayY+DisplayCount*(fontSise+9));
  ObjectSet(lab_str, OBJPROP_BACK, false);
  ObjectSetText(lab_str, text, fontSise, fontName, colour);
    
}

bool tradingAllowed() {
   string noTradeDays[] = {"Sunday"};
   
   for(int i=0; i < ArraySize(noTradeDays); i++) {
      if(day_of_week == noTradeDays[i]) {
      Comment("No Trading Allowed on " + day_of_week);
         return false;
      }
   }
   return true;
}

double getLotSize() {
   if(AccountBalance()/1000 == 0) {
      return LotSize;
   }    
   return ( (AccountBalance()/1000) + 1 ) * LotSize;   
}

//===============================================
//===============================================
//===============================================


bool goodtimetotrade()
  {

   string badtimes[] = {"21:30-07:30"};
   string sep="-";
   ushort u_sep=StringGetCharacter(sep,0);
   string result[];
   int size = ArraySize(badtimes);

   int time=TimeLocal();

   for(int i=0; i<size; i++)
     {

      StringSplit(badtimes[i],u_sep,result);
      int timefrom = StrToTime(result[0]);
      int timeto = StrToTime(result[1]);
      if(time>timefrom && time<timeto)
        {

         return false;   // not a good time
        }
     }

  return true;   // time is fine


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
