//+------------------------------------------------------------------+
//|                                         v1 Expert Advisor.mq4 |
//|                              Copyright © 2008, |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2008"
#property link "http://www..com"

#define EAName "v1 Expert Advisor"
#define  up "Up"
#define  down "Down"
#define  none "None"

extern string separator1="---------------- Entry Settings";
extern bool xb_Alert = false;
extern int xi_Period = 4;
extern string separator2="---------------- Money Management";
extern double Lots=0.33; //lots
extern bool useRiskManagement=false; //money management
extern double RiskPercent=10; //risk in percentage
extern bool Martingale=false; //martingale
extern double Multiplier=1.5; //multiplier
extern double MinProfit=0; //minimum profit to apply the martingale
extern bool UseBasketOptions=false; //use basket loss/profit
extern int BasketProfit=1000; // if equity reaches this level, close trades
extern int BasketLoss=9999; // if equity reaches this negative level, close trades
extern string separator3="---------------- Order Management";
extern int StopLoss=0; //stop loss
extern int TakeProfit=0; //take profit
extern int TrailingStop=150; //trailing stop
extern int TrailingStep=1; //margin allowe to the price before to enable the ts
extern int BreakEven=100; //breakeven
extern bool AddPositions=false; //positions cumulated
extern int MaxOrders=100; //maximum number of orders
extern bool UseHiddenSL=false; //use hidden sl
extern int HiddenSL=5; //stop loss under 15 pîps
extern bool UseHiddenTP=false; //use hidden tp
extern int HiddenTP=10; //take profit under 10 pîps
extern int Magic=0; // magic number
extern int Slippage=3; // how many pips of slippage can you tolorate
extern string separator4="---------------- Filters";
extern bool MAFilter=false; //moving average filter
extern int MAPeriod=20; //ma filter period
extern int MAMethod=1; //ma filter method
extern int MAPrice=0; //ma filter price
extern bool TradeOnSunday=true; //time filter on sunday
extern bool MondayToThursdayTimeFilter=false; //time filter the week
extern int MondayToThursdayStartHour=8; //start hour time filter the week
extern int MondayToThursdayEndHour=17; //end hour time filter the week
extern bool FridayTimeFilter=false; //time filter on friday
extern int FridayStartHour=8; //start hour time filter on friday
extern int FridayEndHour=14; //end hour time filter on friday
extern string separator5="---------------- Extras";

int Slip=3;
int err=0;
int TK;
double Balance=0.0;
double maxEquity;
double minEquity;
double CECount;
double CEProc;
double CEBuy;
double CESell;
double entrySignaliCustomBuyValue;
double entrySignaliCustomSellValue;
bool isBuyEntrySignal;
bool isSellEntrySignal;
bool isTrendSignalUptrend;
bool isTrendSignalDowntrend;
bool placeBuyOrder;
bool placeSellOrder;
// count Renko colour change
string TradeDirection;
extern int CandleCount=1;

//start function
int start()
  {
    isTradingAllowed();      
    initialseBasketTrading();
    initTrendSignalValues();
    initEntrySignalValues();      
    assessEntryConditions();  
    determineLotsize();
    placeTriggeredTrade();
    trailStopOrBreakeven();
    printDashboard();  
    return(0);
  }

//count number of open orders
int countOpenTradesByType(int Type,int Magic)
  {
   int openOrdersCount = 0;   
   for(int j = 0; j < OrdersTotal(); j++)
     {
      OrderSelect(j, SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol( ) == Symbol())
        {
         if((OrderType() == Type && (OrderMagicNumber() == Magic) || Magic==0))
            openOrdersCount++;
        }
     }
   return(openOrdersCount);
  }

//close all orders
int CloseEverything()
  {
   double myAsk;
   double myBid;
   int myTkt;
   double myLot;
   int myTyp;
   int i;
   bool result = false;
   for(i=OrdersTotal(); i>=0; i--)
     {
      OrderSelect(i,SELECT_BY_POS);
      myAsk=MarketInfo(OrderSymbol(),MODE_ASK);
      myBid=MarketInfo(OrderSymbol(),MODE_BID);
      myTkt=OrderTicket();
      myLot=OrderLots();
      myTyp=OrderType();
      switch(myTyp)
        {
         case OP_BUY:
            result=OrderClose(myTkt,myLot,myBid,Slippage,Red);
            CEBuy++;
            break;
         case OP_SELL:
            result=OrderClose(myTkt,myLot,myAsk,Slippage,Red);
            CESell++;
            break;
         case OP_BUYLIMIT:
         case OP_BUYSTOP:
         case OP_SELLLIMIT:
         case OP_SELLSTOP:
            result=OrderDelete(OrderTicket());
        }
      if(result == false)
        {
         Alert("Order",myTkt,"failed to close. Error:",GetLastError());
         Print("Order",myTkt,"failed to close. Error:",GetLastError());
         Sleep(3000);
        }
      Sleep(1000);
      CEProc++;
     }
  }

//trailing stop and breakeven
void assessTrailStopAndBreakEven()
  {
   int breakEven=BreakEven;
   int trailingStop=TrailingStop;
   double currentBid, currentAsk, pointFormat;
   pointFormat=MarketInfo(OrderSymbol(),MODE_POINT);
   if(OrderType()==OP_BUY)
     {
      currentBid=MarketInfo(OrderSymbol(),MODE_BID);
      if(breakEven>0)
        {
         if((currentBid-OrderOpenPrice())>breakEven*pointFormat)
           {
            if((OrderStopLoss()-OrderOpenPrice())<0)
              {
               ModSL(OrderOpenPrice()+0*pointFormat);
              }
           }
        }
      if(trailingStop>0)
        {
         if((currentBid-OrderOpenPrice())>trailingStop*pointFormat)
           {
            if(OrderStopLoss()<currentBid-(trailingStop+TrailingStep-1)*pointFormat)
              {
               ModSL(currentBid-trailingStop*pointFormat);
               return;
              }
           }
        }
     }
   if(OrderType()==OP_SELL)
     {
      currentAsk=MarketInfo(OrderSymbol(),MODE_ASK);
      if(breakEven>0)
        {
         if((OrderOpenPrice()-currentAsk)>breakEven*pointFormat)
           {
            if((OrderOpenPrice()-OrderStopLoss())<0)
              {
               ModSL(OrderOpenPrice()-0*pointFormat);
              }
           }
        }
      if(trailingStop>0)
        {
         if(OrderOpenPrice()-currentAsk>trailingStop*pointFormat)
           {
            if(OrderStopLoss()>currentAsk+(trailingStop+TrailingStep-1)*pointFormat||OrderStopLoss()==0)
              {
               ModSL(currentAsk+trailingStop*pointFormat);
               return;
              }
           }
        }
     }
  }

//stop loss modification function
void ModSL(double ldSL) {bool fm; fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit(),0,CLR_NONE);}

//add positions function
bool AddP()
  {
   int _num=0;
   int _ot=0;
   for(int j=0; j<OrdersTotal(); j++)
     {
      if(OrderSelect(j,SELECT_BY_POS)==true && OrderSymbol()==Symbol()&&OrderType()<3&&((OrderMagicNumber()==Magic)||Magic==0))
        {
         _num++;
         if(OrderOpenTime()>_ot)
            _ot=OrderOpenTime();
        }
     }
   if(_num==0)
      return(true);
   if(_num>0 && ((Time[0]-_ot))>0)
      return(true);
   else
      return(false);

//not enough money message to continue the martingale
   if(TK<0)
     {
      if(GetLastError()==134)
        {
         err=1;
         Print("NOT ENOGUGHT MONEY!!");
        }
      return (false);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void printDashboard()
  {
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";
   string sDirection = "";
   sComment = "renkoCCI_EA" + NL;
//sComment = sComment + "superTrend=" + DoubleToStr(superTrend,Digits) + NL;
   sComment = sComment + "cciBUY=" + DoubleToStr(entrySignaliCustomBuyValue,Digits) + NL;
   sComment = sComment + "cciSELL=" + DoubleToStr(entrySignaliCustomSellValue,Digits) + NL;
   sComment = sComment + sp;
   Comment(sComment);
  }
//+------------------------------------------------------------------+

void isTradingAllowed() {
    if((TradeOnSunday == false && DayOfWeek() == 0) ||
        (MondayToThursdayTimeFilter && DayOfWeek() >= 1 && DayOfWeek() <= 4 && !(Hour() >= MondayToThursdayStartHour && Hour() <= MondayToThursdayEndHour)) ||
        (FridayTimeFilter && DayOfWeek() == 5 && !(Hour() >= FridayStartHour && Hour() <= FridayEndHour))
    )
    {
        CloseEverything();
        printDashboard();
        return(0);
    }
}

void initialseBasketTrading() {
    //Basket profit or loss
    double CurrentProfit= 0;
    double CurrentBasket = 0;
    CurrentBasket = AccountEquity() - AccountBalance();
    if(UseBasketOptions&&CurrentBasket > maxEquity)
        maxEquity = CurrentBasket;
    if(UseBasketOptions && CurrentBasket<minEquity)
        minEquity = CurrentBasket;
    if(UseBasketOptions && CurrentBasket >= BasketProfit || CurrentBasket <= (BasketLoss*(-1)))
    {
        CloseEverything();
        CECount++;
    }
}

void initTrendSignalValues() {
    isTrendSignalUptrend = false;
    isTrendSignalDowntrend = false;

    // double trendSignaliCustomValue = iMA(Symbol(),0,MAPeriod,0,MAMethod,MAPrice,1);

    // if((MAFilter == false) || (MAFilter && Bid > trendSignaliCustomValue))
    //     isTrendSignalUptrend = true;
    // if((MAFilter == false) || (MAFilter && Ask < trendSignaliCustomValue))
    //     isTrendSignalDowntrend = true;

    // double buy = getHalfTrendStatus(4, 1);
    // double sell = getHalfTrendStatus(5, 1);

    // if(buy < 2147483647) {
    //    isTrendSignalUptrend = true;
    // } else if(sell < 2147483647) {
    //   isTrendSignalDowntrend = true;
    // }

    // double fast_uptrend = getFastTrendFilter(1, 1);
    // double fast_downtrend = getFastTrendFilter(0, 1);

    // if(fast_uptrend < 2147483647) {
    //    isTrendSignalUptrend = true;
    // } else if(fast_downtrend < 2147483647) {
    //   isTrendSignalDowntrend = true;
    // }
    
    // double slow_uptrend = getSlowTrendFilter(0, 1);
    // double slow_downtrend = getSlowTrendFilter(1, 1);

    // if(slow_uptrend < 2147483647) {
    //    isTrendSignalUptrend = true;
    // } else if(slow_downtrend < 2147483647) {
    //   isTrendSignalDowntrend = true;
    // }

    // double buy = getHalfTrendStatus(4, 1);
    // double sell = getHalfTrendStatus(5, 1);
    double fast_uptrend = getFastTrendFilter(1, 1);
    double fast_downtrend = getFastTrendFilter(0, 1);
    double slow_uptrend = getSlowTrendFilter(0, 1);
    double slow_downtrend = getSlowTrendFilter(1, 1);

    if(fast_uptrend < 2147483647 && slow_uptrend < 2147483647){
      isTrendSignalUptrend = true;
    } else if(fast_downtrend < 2147483647 && slow_downtrend < 2147483647) {
      isTrendSignalDowntrend = true;
    }

}

double getHalfTrendStatus(int first, int second) {
   return(iCustom(NULL,0,"HalfTrend TT [x5v4]source", 2, first, second));
}

double getFastTrendFilter(int first, int second) {
   return(iCustom(NULL,0,"vh", first, second));
}

double getSlowTrendFilter(int first, int second) {
   return(iCustom(NULL,0,"hull_moving_average_2.0_amp_sr_lines_arrows", "Current time frame", 144, 0, 1.0, false, first, second));
}

void initEntrySignalValues() {
    isBuyEntrySignal = false;
    isSellEntrySignal = false;

    entrySignaliCustomBuyValue = iCustom(Symbol(),0,"!Retrace Finder CCI",xb_Alert,xi_Period,1,1);
    entrySignaliCustomSellValue = iCustom(Symbol(),0,"!Retrace Finder CCI",xb_Alert,xi_Period,2,1);

    if(entrySignaliCustomBuyValue != EMPTY_VALUE)
        isBuyEntrySignal = true;
    if(entrySignaliCustomSellValue != EMPTY_VALUE)
        isSellEntrySignal = true;

    // double buy = getHalfTrendStatus(4, 1);
    // double sell = getHalfTrendStatus(5, 1);

    // if(buy < 2147483647) {
    //   isBuyEntrySignal = true;
    // } else if(sell < 2147483647) {
    //   isSellEntrySignal = true;
    // }
}

void assessEntryConditions() {
    placeBuyOrder = false;
    placeSellOrder = false;
    if(isTrendSignalUptrend && isBuyEntrySignal)
    {
        placeBuyOrder=true;
    }
    if(isTrendSignalDowntrend && isSellEntrySignal)
    {
        placeSellOrder=true;
    }

  //   if(DirectionSignal() && (TradeDirection == up))
  //     {
  //       placeBuyOrder=true;
  //     }
   
  //  if(DirectionSignal() && (TradeDirection == down))
  //     {
  //       placeSellOrder=true;  
  //     }

}

bool DirectionSignal()
{
   int cc;
   TradeDirection = up;
   for (cc = 1; cc <= CandleCount; cc++)
   {
         if (Close[cc] < Open[cc] )
         {
            TradeDirection = none; break;
         }
   }
   if (TradeDirection == up) return(true);
   TradeDirection = down;
   for (cc = 1; cc <= CandleCount; cc++)
   {
         if (Close[cc] > Open[cc] )
         {
            TradeDirection = none; break;
         }
   } 
   if (TradeDirection == down) return(true);
   TradeDirection = none;
   return(false);
}

void determineLotsize() {
    //risk management   
   if(useRiskManagement)
     {
      if(RiskPercent < 0.1 || RiskPercent > 100)
        {
         Comment("Invalid Risk Value.");
         return(0);
        }
      else
        {
         // calculate lotsize for specified risk
         Lots =
            MathFloor(
               (AccountFreeMargin() * AccountLeverage() * RiskPercent*Point*100) /
               (Ask * MarketInfo(Symbol(), MODE_LOTSIZE) * MarketInfo(Symbol(),MODE_MINLOT))) * (MarketInfo(Symbol(),MODE_MINLOT)
            );
        }
     }
   if(useRiskManagement == false)
     {
      Lots=Lots;
     }

//martingale
   if(Balance!=0.0&&Martingale==True)
     {
      if(Balance>AccountBalance())
         Lots=Multiplier*Lots;
      else
         if((Balance+MinProfit)<AccountBalance())
            Lots=Lots/Multiplier;
         else
            if((Balance+MinProfit)>=AccountBalance()&&Balance<=AccountBalance())
               Lots=Lots;
     }
   Balance=AccountBalance();
   if(Lots<0.01)
      Lots=0.01;
   if(Lots>100)
      Lots=100;

}

void placeTriggeredTrade() {

    //positions initialization
   int count = 0, openNumPositions = 0;
   bool openSell, openBuy, closeBuy, closeSell = false;
   openNumPositions=0;
   for(count=0; count<OrdersTotal(); count++)
     {
      OrderSelect(count,SELECT_BY_POS,MODE_TRADES);
      if((OrderType()==OP_SELL||OrderType()==OP_BUY)&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0))
         openNumPositions=openNumPositions+1;
     }
   if(openNumPositions >= 1)
     {
      openSell = false;
      openBuy = false;
     }
   int stopLoss=StopLoss;
   int takeProfit=TakeProfit;

//entry conditions verification
   if(placeSellOrder)
     {
      openSell = true;
      openBuy = false;
     }
   if(placeBuyOrder)
     {
      openBuy = true;
      openSell = false;
     }

//conditions to close position
  //  if((placeSellOrder)||(UseHiddenSL&&(OrderOpenPrice()-Bid)/Point>=HiddenSL)||(UseHiddenTP&&(Ask-OrderOpenPrice())/Point>=HiddenTP))
  //    {
  //        closeBuy = true;
  //    }
  //  if((placeBuyOrder)||(UseHiddenSL&&(Ask-OrderOpenPrice())/Point>=HiddenSL)||(UseHiddenTP&&(OrderOpenPrice()-Bid)/Point>=HiddenTP))
  //    {
  //        closeSell = true;
  //    }
  //  for(count=0; count<OrdersTotal(); count++)
  //    {
  //     OrderSelect(count,SELECT_BY_POS,MODE_TRADES);
  //     if(OrderType()==OP_BUY&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0))
  //       {
  //        if(closeBuy)
  //          {
  //           OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Red);
  //           return(0);
  //          }
  //       }
  //     if(OrderType()==OP_SELL&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0))
  //       {
  //        if(closeSell)
  //          {
  //           OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);
  //           return(0);
  //          }
  //       }
  //    }
   double SLI=0,TPI=0;
   int TK=0;

//open position
   if((AddP()&&AddPositions&&openNumPositions<=MaxOrders)||(openNumPositions==0&&!AddPositions))
     {
      if(openSell)
        {
         if(takeProfit==0)
            TPI=0;
         else
            TPI=Bid-takeProfit*Point;
         if(stopLoss==0)
            SLI=0;
         else
            SLI=Bid+stopLoss*Point;
         TK=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,SLI,TPI,EAName,Magic,0,Red);
         openSell = false;
         return(0);
        }
      if(openBuy)
        {
         if(takeProfit==0)
            TPI=0;
         else
            TPI=Ask+takeProfit*Point;
         if(stopLoss==0)
            SLI=0;
         else
            SLI=Ask-stopLoss*Point;
         TK=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,SLI,TPI,EAName,Magic,0,Lime);
         openBuy = false;
         return(0);
        }
    }     
}

void trailStopOrBreakeven() {
    for(int j=0; j<OrdersTotal(); j++)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0))
           {
            assessTrailStopAndBreakEven();
           }
        }
    }
}