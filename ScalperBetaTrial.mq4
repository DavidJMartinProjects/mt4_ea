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
input int      StartHour = 1;
input int      EndHour = 21;
input double      risk = 1;
input double      maxLotSize = 0.6;

bool sells_open = false;
bool buys_open = false;
bool orders_open = false;

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

int count_wins = 0;
int count_losses = 0;

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
   showDashboard();
   if(CheckTradingTimes() == true && tradingAllowed() == true) {      
      double buy = getHalfTrendStatus(5, 1);
      double sell = getHalfTrendStatus(6, 1);
      if(sell != EMPTY_VALUE && sell < 2147483647) {         
         if(orders_open == false) {            
            OrderSend(_Symbol,OP_SELL,CalcLots(risk),Bid,Slippage,0,0,"SELL",MagicNumber); 
            sells_open = true;
            buys_open = false;
            orders_open = true;
            trades_taken++;
         } else if(orders_open == true && buys_open == true) {
            CloseAllOpenTrades();
            OrderSend(_Symbol,OP_SELL,CalcLots(risk),Bid,Slippage,0,0,"SELL",MagicNumber); 
            sells_open = true;
            buys_open = false;
            orders_open = true;
            trades_taken++;
         }
      } else if(buy != EMPTY_VALUE && buy < 2147483647) {
         if(orders_open == false) {            
            OrderSend(_Symbol,OP_BUY,CalcLots(risk),Ask,Slippage,0,0,"BUY",MagicNumber);  
            sells_open = false;
            buys_open = true;   
            orders_open = true;      
            trades_taken++;   
         } else if(orders_open == true && sells_open == true) {
            CloseAllOpenTrades();
            OrderSend(_Symbol,OP_BUY,CalcLots(risk),Ask,Slippage,0,0,"BUY",MagicNumber);
            sells_open = false;
            buys_open = true; 
            orders_open = true;
            trades_taken++;
         }
      }
   } else {      
      CloseAllOpenTrades();
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


//////////////////////////////////////////////////////////////////
//trading hours, by Steve Hopwood and Baluda
bool CheckTradingTimes() 
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
if(Hour()<StartHour && Hour()< EndHour) {
   tradingHoursStatus = "Disabled.";
   return false;
   } else {
   tradingHoursStatus = "Enabled.";
   return true;
   }

}//End bool CheckTradingTimes() 

//+------------------------------------------------------------------+
//| Initialize Trading Hours Array                                   |
//+------------------------------------------------------------------+

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

void Display(string text)
{
  string lab_str = "EA-" + IntegerToString(DisplayCount);  
  double ofset = 0;  
  
  ObjectCreate("EA-BG",OBJ_RECTANGLE_LABEL,0,0,0);
  ObjectSet("EA-BG", OBJPROP_XDISTANCE, DisplayX-20);
  ObjectSet("EA-BG", OBJPROP_YDISTANCE, DisplayY-10);
  ObjectSet("EA-BG", OBJPROP_XSIZE,303);
  ObjectSet("EA-BG", OBJPROP_YSIZE,327);
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
   string noTradeDays[] = {"Sunday", "Monday"};
   
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
//   tmpLot = NormalizeDouble(AccountBalance()*Risk/1000,2);
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