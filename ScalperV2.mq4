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
input double   LotSize=0.4;
input bool     UseMFI=true;
input int      Slippage=20;
input int      MagicNumber=5555;
input int      StartHour = 1;
input int      EndHour = 21;
input double   risk = 1;
input double   maxLotSize = 0.6;

bool sells_open = false;
bool buys_open = false;
bool orders_open = false;
int day_running = 0;
string previous_day_of_week = "";
const string noTradeDays[] = {"Sunday"};
color tradeStatuscolour = Yellow;

extern string __c8="----------------------------------";
extern bool    KeepTextOnTop     = true;//Disable the chart in foreground CrapTx setting so the candles do not obscure the text
extern int     DisplayX          = 100;
extern int     DisplayY          = 100;
extern int     fontSise          = 10;
extern string  fontName          = "Courier New";
extern color   colour            = Yellow;

int orderTicket = 0;
double trades_taken = 0;
string day_of_week = "";
int days_running = 0;
int count_wins = 0;
int count_losses = 0;
int lastDayCount = 0;

int DisplayCount = 0;

const double opening_balance = AccountBalance();
double balance_after_last_trade = AccountBalance();

////////////////////////////////////////////////////////////////////////////////////////
// trading hours variables
int 	          tradeHours[];
string          tradingHoursDisplay;//tradingHours is reduced to "" on initTradingHours, so this variable saves it for screen display.
bool            TradeTimeOk;
datetime        OldBarsTime,OldDayBarTime;
int TradingHourTime;
extern bool    UseLocalTime = FALSE;//true:TimeLocal(), false:TimeCurrent()
string tradingHoursStatus;

////////////////////////////////////////////////////////////////////////////////////////


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
   getDayOfWeek();
   showDashboard();
   if(CheckAllowedTradingHour() == true && CheckAllowedTradingDay() == true) {
      double buy_entry_signal = getHalfTrendStatus(5, 1);
      double sell_entry_signal = getHalfTrendStatus(6, 1);
      if(sell_entry_signal != EMPTY_VALUE && sell_entry_signal < 2147483647) {
         if(orders_open == false) {
            PlaceSellOrder();
         } else if(orders_open == true && buys_open == true) {
            CloseAllOpenTrades();
            PlaceSellOrder();
         }
      } else if(buy_entry_signal != EMPTY_VALUE && buy_entry_signal < 2147483647) {
         if(orders_open == false) {
            PlaceBuyOrder();
         } else if(orders_open == true && sells_open == true) {
            CloseAllOpenTrades();
            PlaceBuyOrder();
         }
      }
   } else {
      CloseAllOpenTrades();
   }

  }
//+------------------------------------------------------------------+
void PlaceSellOrder() {
    OrderSend(_Symbol,OP_SELL,CalcLots(risk),Bid,Slippage,0,0,"SELL",MagicNumber);
    orders_open = true;
    adjustSellCounters();
}

void PlaceBuyOrder() {
    OrderSend(_Symbol,OP_BUY,CalcLots(risk),Ask,Slippage,0,0,"BUY",MagicNumber);
    orders_open = true;
    adjustBuyCounters();
}

void CloseAllOpenTrades() {
   for(int i=OrdersTotal(); i>=0; i--) {
      if(OrderSelect(i, SELECT_BY_POS) == true) {
         if(OrderSymbol() == Symbol()) {
            OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
            OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
         }
      }
   }
   orders_open = false;
}

double getHalfTrendStatus(int first, int second) {
   return(iCustom(NULL,0,"half-trend nrp", 2, false, true, first, second));
}

int TotalOpenOrders() {
   int total_orders = 0;
   for(int order = 0; order < OrdersTotal(); order++) {
      if(OrderSelect(order,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber() == MagicNumber && OrderSymbol() == _Symbol) {
            total_orders++;
      }
   }
   return(total_orders);
}


//////////////////////////////////////////////////////////////////
//trading hours, by Steve Hopwood and Baluda
bool CheckAllowedTradingHour()
{
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Trade 24 hours if no input is given
//	if ( ArraySize( tradeHours ) == 0 ) return ( true );
//
//	// Get local time in minutes from midnight
//    if (UseLocalTime) TradingHourTime = TimeLocal();
//     else if (!UseLocalTime) TradingHourTime = TimeCurrent();
//    int time = TimeHour(TradingHourTime) * 60 + TimeMinute(TradingHourTime);
//
//	// Don't you love this?
//	int i = 0;
//	while ( time >= tradeHours[i] )
//	{
//		if ( i == ArraySize( tradeHours ) ) break;
//		i++;
//	}
//	if ( i % 2 == 1 ) return ( true );
//	return ( false );

//+------------------------------------------------------------------+
//|               Day&Time Filter                                    |
//+------------------------------------------------------------------+
if(Hour()<StartHour && Hour() > EndHour) {
   tradingHoursStatus = "Disabled.";
        return false;
   } else {
   tradingHoursStatus = "Enabled.";
        return true;
   }

}//End bool CheckTradingTimes()

void adjustSellCounters() {
   tradeStatuscolour = Red;    
    sells_open = true;
    buys_open = false;
    orders_open = true;
    trades_taken++;
}

void adjustBuyCounters() {
    tradeStatuscolour = Lime;    
    sells_open = false;
    buys_open = true;
    orders_open = true;
    trades_taken++;
}

//+------------------------------------------------------------------+
//| Initialize Trading Hours Array                                   |
//+------------------------------------------------------------------+

void showDashboard() {

      UpdateWinLossStatus();

      // Build Dashboard Messages
      DisplayCount=0;
      AddDashBoardMessage("---------------------------");
      AddDashBoardMessage("Oh Dear! EA Dashboard");
      AddDashBoardMessage("---------------------------");
      AddDashBoardMessage("");      
      AddDashBoardMessage("Days running: " + day_running);
      AddDashBoardMessage("Day of week: " + day_of_week);
      AddDashBoardMessage("Trading Status: " + tradingHoursStatus + " " +Hour());
      AddDashBoardMessage("Strategy: Scalper");
      AddDashBoardMessage("Fixed LotSize: " + CalcLots(risk));
      AddDashBoardMessage("");
      AddDashBoardMessage("Trades Taken: " + trades_taken);
      AddDashBoardMessage("Winners: " + count_wins);
      AddDashBoardMessage("Losers: " + count_losses);
      AddDashBoardMessage("");
      AddDashBoardMessage("Profit this session: " + DoubleToString(( AccountBalance() - opening_balance ), 2));
      AddDashBoardMessage("---------------------------");
      ObjectDelete(DisplayCount);
      AddDashBoardTradeStatusMessage(getOpenOrderDetail());


}



void UpdateWinLossStatus() {
   if(balance_after_last_trade != AccountBalance() && balance_after_last_trade - AccountBalance() < 5 ) {
      count_wins++;
   }
   else if(balance_after_last_trade != AccountBalance() && balance_after_last_trade - AccountBalance() > 5 ) {
      count_losses++;
   }
   balance_after_last_trade = AccountBalance();
}

void AddDashBoardMessage(string message) {

   DisplayCount++;
   Display(message);
}

void AddDashBoardTradeStatusMessage(string message) {

   DisplayCount++;
   DisplayTradeStatus(message);
}

void Display(string text)
{
  string lab_str = "EA-" + IntegerToString(DisplayCount);
  double ofset = 0;

  ObjectCreate("EA-BG",OBJ_RECTANGLE_LABEL,0,0,0);
  ObjectSet("EA-BG", OBJPROP_XDISTANCE, DisplayX-20);
  ObjectSet("EA-BG", OBJPROP_YDISTANCE, DisplayY-10);
  ObjectSet("EA-BG", OBJPROP_XSIZE,303);
  ObjectSet("EA-BG", OBJPROP_YSIZE,367);
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
string getOpenOrderDetail() {

    if(sells_open == true) {
        return "SELL Order Open";
    } 
    return "BUY Order Open";
}

void DisplayTradeStatus(string text) {
  string lab_str = "EA-" + IntegerToString(DisplayCount);  
  double ofset = 0;

  ObjectCreate(lab_str, OBJ_LABEL, 0, 0, 0);
  ObjectSet(lab_str, OBJPROP_CORNER, 0);
  ObjectSet(lab_str, OBJPROP_XDISTANCE, DisplayX + ofset);
  ObjectSet(lab_str, OBJPROP_YDISTANCE, DisplayY+DisplayCount*(fontSise+9));
  ObjectSet(lab_str, OBJPROP_BACK, false);
  ObjectSetText(lab_str, text, 16, fontName, tradeStatuscolour);
  DisplayCount++;
  //getTradeOrderColor(text)

}

//string getTradeOrderColor() { 
//   Print("sells open: " + sells_open);    
//    if (sells_open == true) {
//        tradeStatuscolour = ColorToString(Red);
//    } 
//    if(sells_open == false) {
//      tradeStatuscolour = ColorToString(Yellow);
//    }
//    return tradeStatuscolour;
//}

bool CheckAllowedTradingDay() {

   getDayOfWeek();
   if(previous_day_of_week == "") {
        previous_day_of_week = day_of_week;
   }

   if(previous_day_of_week != day_of_week) {
        days_running++;
   }

   for(int i=0; i < ArraySize(noTradeDays); i++) {
      if(day_of_week == noTradeDays[i]) {
      Comment("No Trading Allowed on " + day_of_week);
         return false;
      }
   }
   return true;
}

double CalcLots(double Risk)
{
//   double tmpLot = 0, MinLot = 0, MaxLot = 0;
//   MinLot = MarketInfo(Symbol(),MODE_MINLOT);
//   MaxLot = MarketInfo(Symbol(),MODE_MAXLOT);
//   tmpLot = NormalizeDouble(AccountBalance()*Risk/1000,1.5);
//
//   if(tmpLot < MinLot)
//   {
//      Print("LotSize is Smaller than the broker allow minimum Lot!");
//      return(MinLot);
//   }
//   if(tmpLot > maxLotSize)
//   {
//      Print ("LotSize is Greater than the allow minimum Lot!");
//      return(maxLotSize);
//   }
//   return(tmpLot);
   return LotSize;
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


